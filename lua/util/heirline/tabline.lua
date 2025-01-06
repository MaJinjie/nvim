--=============================== config
local config = {
	offset = {
		left = {
			["neo-tree"] = { title = "neo-tree" },
		},
		right = {},
	},
}
local colors = {
	background = { bg = "dark_hard" },
	active = { fg = "light_soft", bg = "dark_soft", bold = true },
	inactive = { fg = "gray" },
	visible = { fg = "gray", bg = "dark" },
	flags = {
		modified = { fg = "bright_yellow" },
		readonly = { fg = "bright_orange" },
		close = { fg = "gray" },
	},
	picker = { fg = "bright_red", bold = true },
	offset = { fg = "bright_yellow" },
}
--=============================== utils
local utils = require("util.heirline.utils")

local buflist_cache = {} ---@type number[]
local buflist_display_cache = {} ---@type table<number, string>
local buflist_path_cache = {} ---@type table<number, string>

--=============================== components
local components = {}

function components.placeholder()
	return { provider = "%=" }
end

--=============================== components.offset

function components.offset(dir)
	return {
		condition = function(self)
			local wins = vim.api.nvim_tabpage_list_wins(0)
			local win = dir == "left" and wins[0] or wins[#wins]
			local bufnr = vim.api.nvim_win_get_buf(win)
			self.winid = win

			for filetype, info in ipairs(config.offset[dir]) do
				if vim.bo[bufnr].filetype == filetype then
					for k, v in pairs(info) do
						self[k] = v
					end
					break
				end
			end
		end,
		update = { "BufWinEnter" },
		provider = function(self)
			local title = self.title
			local width = vim.api.nvim_win_get_width(self.winid)
			local pad = math.ceil((width - #title) / 2)
			return string.rep(" ", pad) .. title .. string.rep(" ", pad)
		end,
		hl = colors.offset,
	}
end

--=============================== components.bufferline
function components.bufferline()
	local file_picker = {
		condition = function(self)
			return self._show_picker
		end,
		update = false,
		init = function(self)
			local bufname = vim.api.nvim_buf_get_name(self.bufnr)
			bufname = vim.fn.fnamemodify(bufname, ":t")
			local label = bufname:sub(1, 1)
			local i = 2
			while self._picker_labels[label] do
				if i > #bufname then
					break
				end
				label = bufname:sub(i, i)
				i = i + 1
			end
			self._picker_labels[label] = self.bufnr
			self.label = label
		end,
		provider = function(self)
			return self.label .. " "
		end,
		hl = colors.picker,
	}

	local file_icon = {
		init = function(self)
			self.icon, self.icon_hl = require("mini.icons").get("file", self.path)
		end,
		provider = function(self)
			return self.icon and self.icon .. " " or ""
		end,
		hl = function(self)
			return self.icon_hl
		end,
	}

	local file_name = {
		init = function(self)
			local file = self.spath or self.path

			self.basename = file == "" and "[No Name]" or vim.fs.basename(file)
			self.dirname = file ~= self.basename and vim.fs.dirname(file) or ""
		end,
		{
			condition = function(self)
				return self.dirname ~= ""
			end,
			provider = function(self)
				return self.dirname .. "/"
			end,
			hl = colors.inactive,
		},
		{
			condition = function(self)
				return self.basename ~= ""
			end,
			provider = function(self)
				return self.basename
			end,
		},
	}

	local file_flags = {
		fallthrough = false,
		{
			condition = function(self)
				return vim.bo[self.bufnr].modified
			end,
			provider = " ●",
			hl = colors.flags.modified,
		},
		{
			condition = function(self)
				return not vim.bo[self.bufnr].modifiable or vim.bo[self.bufnr].readonly
			end,
			provider = " ",
			hl = colors.flags.readonly,
		},
		{
			provider = " 󰅖",
			hl = colors.flags.close,
			on_click = {
				callback = function(_, minwid)
					vim.schedule(function()
						require("util.keymap").buf_delete(minwid)
						vim.cmd.redrawtabline()
					end)
				end,
				minwid = function(self)
					return self.bufnr
				end,
				name = "heirline_tabline_close_buffer_callback",
			},
		},
	}

	return {
		init = function(self)
			self.path = buflist_path_cache[self.bufnr]
			self.spath = buflist_display_cache[self.bufnr]
		end,
		hl = function(self)
			if self.is_active then
				return colors.active
			elseif self.is_visible then
				return colors.visible
			else
				return colors.inactive
			end
		end,
		on_click = {
			callback = function(_, minwid, _, button)
				if button == "l" then
					vim.api.nvim_win_set_buf(0, minwid)
				end
			end,
			minwid = function(self)
				return self.bufnr
			end,
			name = "heirline_tabline_buffer_callback",
		},
		{
			fallthrough = false,
			file_picker,
			file_icon,
		},
		file_name,
		file_flags,
	}
end

function components.bufferlines()
	return utils.make_buflist(
		utils.padding(components.bufferline(), true),
		{ provider = " ", hl = { fg = "gray" } },
		{ provider = " ", hl = { fg = "gray" } },
		function()
			return buflist_cache
		end,
		false
	)
end

--=============================== components.tabpage
function components.tabpage()
	return {
		provider = function(self)
			return "%" .. self.tabnr .. "T " .. self.tabnr .. " %T"
		end,
		hl = function(self)
			return self.is_active and colors.active or colors.inactive
		end,
	}
end
function components.tabpages()
	return {
		condition = function()
			return #vim.api.nvim_list_tabpages() >= 2
		end,
		utils.make_tablist(utils.padding(components.tabpage(), true)),
	}
end

--=============================== setup
local M = {}

M.init = function()
	M.config = {
		hl = colors.background,
		components.offset("left"),
		components.bufferlines(),
		components.placeholder(),
		components.tabpages(),
		components.offset("right"),
	}
end

M.setup = function()
	local get_bufs = function()
		return vim.tbl_filter(function(bufnr)
			return vim.api.nvim_get_option_value("buflisted", { buf = bufnr })
		end, vim.api.nvim_list_bufs())
	end

	local function simply_path(bufs, n)
		local spath_bufs = {}
		for _, buf in ipairs(bufs) do
			local spath = buflist_path_cache[buf]:match(("[^/]*/"):rep(n - 1) .. "[^/]*$")
			if spath then
				spath_bufs[spath] = spath_bufs[spath] or {}
				table.insert(spath_bufs[spath], buf)
			end
		end

		for spath, sbufs in pairs(spath_bufs) do
			if #sbufs == 1 then
				buflist_display_cache[sbufs[1]] = spath
			else
				simply_path(sbufs, n + 1)
			end
		end
	end

	vim.api.nvim_create_autocmd({ "VimEnter", "BufAdd", "BufDelete" }, {
		callback = function()
			vim.schedule(function()
				local bufs = get_bufs()
				for i, buf in ipairs(bufs) do
					buflist_cache[i] = buf
					buflist_path_cache[buf] = vim.api.nvim_buf_get_name(buf)
				end
				for i = #bufs + 1, #buflist_cache do
					local buf = buflist_cache[i]
					buflist_cache[i] = nil
					buflist_path_cache[buf] = nil
					buflist_display_cache[buf] = nil
				end

				simply_path(bufs, 1)
				-- check how many buffers we have and set showtabline accordingly
				if #buflist_cache > 1 then
					vim.o.showtabline = 2 -- always
				elseif vim.o.showtabline ~= 1 then -- don't reset the option if it's already at default value
					vim.o.showtabline = 1 -- only when #tabpages > 1
				end
			end)
		end,
	})

	vim.api.nvim_create_user_command("BufferLinePick", function(args)
		local tabline = require("heirline").tabline
		local buflist = tabline._buflist[1]
		buflist._picker_labels = {}
		buflist._show_picker = true
		vim.cmd.redrawtabline()
		local char = vim.fn.getcharstr()
		local bufnr = buflist._picker_labels[char]
		if bufnr then
			vim.api.nvim_win_set_buf(0, bufnr)
		end
		buflist._show_picker = false
		vim.cmd.redrawtabline()
	end, { desc = "Pick a bufferline" })
end
return M
