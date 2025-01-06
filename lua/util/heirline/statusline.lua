local icons = require("config.theme").icons
--=============================== config
local colors = {
	section = {
		{ fg = "black", bg = "light4" },
		{ fg = "light1", bg = "dark2" },
		{ fg = "light1", bg = "dark1" },
		[0] = { bg = "dark1" },
	},
	mode = {
		normal = { bg = "light4", fg = "black", bold = true },
		insert = { bg = "bright_blue", fg = "black", bold = true },
		visual = { bg = "bright_yellow", fg = "black", bold = true },
		select = { bg = "bright_aqua", fg = "black", bold = true },
		replace = { bg = "bright_purple", fg = "black", bold = true },
		command = { bg = "bright_orange", fg = "black", bold = true },
		terminal = { bg = "bright_green", fg = "black", bold = true },
	},
	diagnostic = {
		error = { fg = "bright_red" },
		warn = { fg = "bright_yellow" },
		info = { fg = "bright_blue" },
		hint = { fg = "bright_aqua" },
	},
	branch = {},
	recording_macro = { fg = "bright_yellow", bold = true },
	diff = {
		added = { fg = "bright_green" },
		changed = { fg = "bright_orange" },
		removed = { fg = "bright_red" },
	},
	lsp = {
		active = { fg = "bright_green", bold = true },
	},
	background = { bg = "dark1" },
}

local separators = {
	section = { left = "", right = "" }, -- 设置分隔符
	component = { left = "", right = "" }, -- 设置组件间分隔符
	padding = { left = " ", right = " " },
}

--=============================== utils
local utils = require("util.heirline.utils")

--- 连接多个sections
---@param sections table[]
---@param dir "left"|"right"
function utils.sections(sections, dir)
	local function wrap_hl(i)
		return function(self)
			local hl = (function()
				local hl = sections[i].hl
				if type(hl) == "function" then
					return hl(self)
				elseif type(hl) == "string" then
					return vim.api.nvim_get_hl(0, { name = hl, link = false })
				else
					return hl or {}
				end
			end)()

			-- section.hl.bg -> separator.hl.fg
			return { fg = hl.bg or colors.section[i].bg, bg = colors.section[self.hl_map[i]].bg }
		end
	end

	if dir == "right" then
		sections = vim.iter(sections):rev():totable()
	end

	local res = {
		static = {
			conditions = {},
			hl_map = {}, -- [i] = j 表示第i个section的下一个section是j
		},
		init = function(self)
			-- 计算所有conditions
			local last = nil
			for i, condition in ipairs(self.conditions) do
				if type(condition) ~= "function" or condition() then
					if last then
						self.hl_map[last] = i
					end
					last = i
				end
			end
			if last then
				self.hl_map[last] = 0
			end
		end,
		after = function(self)
			self.hl_map = {}
		end,
	}

	for i = 1, #sections do
		local section = {
			init = sections[i].init,
			static = sections[i].static,
			condition = function(self)
				return self.hl_map[i] ~= nil
			end,
			hl = colors.section[i], -- section默认高亮
		}
		res.static.conditions[i] = sections[i].condition or true

		-- 将section的init static condition属性上升，其中condition属性提前计算
		sections[i].init = nil
		sections[i].static = nil
		sections[i].condition = nil

		table.insert(section, sections[i])

		table.insert(section, 1 + (dir == "left" and #section or 0), {
			provider = separators.section[dir],
			hl = wrap_hl(i),
		})
		table.insert(res, 1 + (dir == "left" and #res or 0), section)
	end

	return res
end

---连接多个components
---
--- 1. 有condition a b c 依次递进，a若不满足，bc一定不显示，此时a的condition可以作为全局
--- 2. 必须要有一个组件是一定显示的
--- 两个条件满足其中之一
---@param components table[]
---
--- main: 第一个组件的condition控制整个section的可见性
---@param opts? {dir?:"left"|"right", main?:boolean}
function utils.components(components, opts)
	opts = opts or {}
	local dir = opts.dir or "left"
	local main = vim.F.if_nil(opts.main, false)
	local res = {}

	for i = 1, #components do
		if i > 1 then
			table.insert(res, {
				provider = separators.component[dir],
				condition = function()
					local condition1 = components[i - 1].condition
					local condition2 = components[i].condition
					return (not condition1 or condition1()) and (not condition2 or condition2())
				end,
			})
		end
		table.insert(res, components[i])
	end
	if main then
		res.condition = components[1].condition
	end

	return res
end

--=============================== components
local components = {}

---占位符
function components.placeholder()
	return { provider = "%=" }
end
--=============================== components.default
components.default = {}

function components.default.mode()
	local vi_mode = {
		restrict = { hl = false },
		init = function(self)
			self.mode = vim.fn.mode(1)
			local mode = ""
			for k, _ in pairs(self.mode_names) do
				if self.mode:match("^" .. k) and #k > #mode then
					mode = k
				end
			end
			self.mode = mode
		end,
		static = {
			mode_names = {
				n = { "NORMAL", "N" },
				no = { "O-PENDING", "O" },
				ni = { "I-NORMAL", "N" },
				nt = { "T-NORMAL", "N" },
				v = { "VISUAL", "v" },
				V = { "V-LINE", "V" },
				["\22"] = { "V-BLOCK", "" },
				s = { "SELECT", "s" },
				S = { "S-LINE", "S" },
				["\19"] = { "S-BLOCK", "" },
				i = { "INSERT", "I" },
				R = { "REPLACE", "R" },
				c = { "COMMAND", "C" },
				t = { "TERMINAL", "T" },
			},
			mode_colors = {
				n = colors.mode.normal,
				no = colors.mode.normal,
				ni = colors.mode.normal,
				nt = colors.mode.normal,
				v = colors.mode.visual,
				V = colors.mode.visual,
				["\22"] = colors.mode.visual,
				s = colors.mode.select,
				S = colors.mode.select,
				["\19"] = colors.mode.select,
				i = colors.mode.insert,
				R = colors.mode.replace,
				c = colors.mode.command,
				t = colors.mode.terminal,
				[""] = colors.mode.none,
			},
		},
		hl = function(self)
			return self.mode_colors[self.mode]
		end,
		update = { "ModeChanged", pattern = "*:*" },
		{
			flexible = 10,
			{
				provider = function(self)
					return self.mode_names[self.mode][1]
				end,
			},
			{
				provider = function(self)
					return self.mode_names[self.mode][2]
				end,
			},
		},
	}
	return vi_mode
end

---获取git分支
function components.default.branch()
	return {
		condition = function()
			return vim.b.gitsigns_head ~= nil
		end,
		hl = colors.branch,
		provider = function()
			return icons.misc.branch .. vim.b.gitsigns_head
		end,
	}
end

function components.default.diff()
	return {
		condition = function()
			return vim.b.gitsigns_status and vim.b.gitsigns_status ~= ""
		end,
		{
			condition = function()
				return vim.b.gitsigns_status_dict.added > 0
			end,
			provider = function()
				return icons.git.added .. vim.b.gitsigns_status_dict.added
			end,
			hl = colors.diff.added,
		},
		{
			condition = function()
				return vim.b.gitsigns_status_dict.changed > 0
			end,
			provider = function()
				return icons.git.changed .. vim.b.gitsigns_status_dict.changed
			end,
			hl = colors.diff.changed,
		},
		{
			condition = function()
				return vim.b.gitsigns_status_dict.removed > 0
			end,
			provider = function()
				return icons.git.removed .. vim.b.gitsigns_status_dict.removed
			end,
			hl = colors.diff.removed,
		},
	}
end

---获取当前文件的root
function components.default.dir()
	local dir_icon = {
		init = function(self)
			self.icon, self.icon_hl = require("mini.icons").get("directory", self.dir)
		end,
		provider = function(self)
			return self.icon and self.icon .. " " or ""
		end,
		hl = function(self)
			return self.icon_hl
		end,
	}
	local dir_name = {
		provider = function(self)
			local dir_name = vim.fn.fnamemodify(self.dir, ":t")
			return dir_name
		end,
	}
	return {
		init = function(self)
			self.dir = require("util.root").root({ follow = true })
		end,
		dir_icon,
		dir_name,
	}
end

---获取当前文件名
function components.default.file()
	local file_icon = {
		init = function(self)
			self.icon, self.icon_hl = require("mini.icons").get("file", self.file)
		end,
		provider = function(self)
			return self.icon and self.icon .. " " or ""
		end,
		hl = function(self)
			return self.icon_hl
		end,
	}
	local file_name = {
		provider = function(self)
			local filename = vim.fn.fnamemodify(self.file, ":t")
			if filename == "" then
				return "[No Name]"
			end
			return filename
		end,
	}
	local file_flags = {
		{
			condition = function()
				return vim.bo.modified
			end,
			provider = "●",
			hl = { fg = "bright_green" },
		},
		{
			condition = function()
				return not vim.bo.modifiable or vim.bo.readonly
			end,
			provider = "",
			hl = { fg = "bright_orange" },
		},
	}
	return {
		init = function(self)
			self.file = vim.api.nvim_buf_get_name(0)
		end,
		condition = function()
			return vim.bo.buftype == ""
		end,
		file_icon,
		file_name,
		file_flags,
	}
end

function components.default.file_type()
	local file_icon = {
		init = function(self)
			self.icon, self.icon_hl = require("mini.icons").get("extension", vim.api.nvim_buf_get_name(0))
		end,
		provider = function(self)
			return self.icon and self.icon .. " " or ""
		end,
		hl = function(self)
			return self.icon_hl
		end,
	}
	local file_type = {
		provider = function()
			return vim.bo.filetype
		end,
	}
	return {
		condition = function()
			return vim.bo.buftype == "" and vim.bo.filetype ~= nil and vim.bo.filetype ~= ""
		end,
		file_icon,
		file_type,
	}
end

function components.default.active_lsp()
	return {
		condition = function()
			return #vim.lsp.get_clients({ bufnr = 0 }) > 0
		end,
		update = { "LspAttach", "LspDetach" },
		provider = function()
			local names = {}
			for _, server in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
				table.insert(names, server.name)
			end
			return " [" .. table.concat(names, " ") .. "]"
		end,
		hl = colors.lsp.active,
	}
end

---获取当前文件的诊断信息

function components.default.diagnostic(cat)
	local severities = { "ERROR", "WARN" }
	local diagnostic = {
		condition = function()
			-- 检查诊断是否启用，并且有对应的诊断条目
			return vim.diagnostic.is_enabled({ bufnr = 0 }) and #vim.diagnostic.get(0, { severity = severities }) > 0
		end,
		update = { "DiagnosticChanged", "BufEnter" },
	}

	-- 遍历 severities，动态生成子组件
	for _, severity in ipairs(severities) do
		table.insert(diagnostic, {
			condition = function(self)
				local diagnostics = vim.diagnostic.get(0, { severity = vim.diagnostic.severity[severity:upper()] })
				if #diagnostics > 0 then
					self.count = #diagnostics
					return true
				end
				return false
			end,
			provider = function(self)
				return icons.diagnostic[severity:upper()] .. self.count
			end,
			hl = colors.diagnostic[severity:lower()],
		})
	end
	return diagnostic
end

function components.default.recording_macro()
	local macro = {
		condition = function()
			return vim.fn.reg_recording() ~= ""
		end,
		update = { "RecordingEnter", "RecordingLeave" },
		hl = colors.recording_macro,
		provider = function(self)
			vim.print(self.id)
			return " [recording @" .. vim.fn.reg_recording() .. "]"
		end,
	}
	return macro
end

function components.default.showcmd()
	vim.o.showcmd = true
	vim.o.showcmdloc = "statusline"
	local showcmd = {
		provider = "%2(%S%)",
	}
	return showcmd
end

---获取标尺
function components.default.rule()
	return { provider = "%2l:%-2c" }
end

---获取百分比
function components.default.percentage()
	return { provider = "%3P" }
end

setmetatable(components.default, {
	__call = function(self)
		return {
			hl = colors.background,
			-- left
			utils.sections({
				-- a
				utils.padding(self.mode(), true),
				-- b
				utils.components({
					utils.padding(self.branch(), true),
					utils.padding(self.diff(), true),
				}, { main = true }),
			}, "left"),
			components.placeholder(),
			{
				fallthrough = false,
				self.recording_macro(),
				self.active_lsp(),
			},
			components.placeholder(),
			utils.sections({
				-- x
				utils.padding(self.diagnostic(), true),
				-- y
				utils.padding(self.file_type(), true),
				-- z
				vim.tbl_extend(
					"force",
					self.mode(),
					{ provider = false },
					utils.components({
						utils.padding(self.rule(), true),
						utils.padding(self.percentage(), true),
					}, { dir = "right" })
				),
			}, "right"),
		}
	end,
})

--=============================== components.lazy
components.lazy = {}

setmetatable(components.lazy, {
	__call = function(_)
		local stats = require("lazy").stats()
		local section1 = {
			provider = "Lazy 󰒲 ",
			hl = colors.mode.normal,
		}
		local section2 = {
			provider = ("loaded: %d/%d"):format(stats.loaded, stats.count),
		}
		local section3 = {
			provider = ("startuptime: %.2fms"):format(stats.startuptime),
		}

		return {
			hl = colors.background,
			utils.sections({
				{
					provider = ("startuptime: %.2fms"):format(stats.startuptime),
				},
			}, "left"),
			components.placeholder(),
		}
	end,
})

--=============================== setup
local M = {}

M.init = function()
	M.config = {
		fallthrough = false,
		{
			condition = function()
				return vim.bo.filetype == "lazy"
			end,
			init = function(self)
				self[1] = self:new(components.lazy())
			end,
		},
		{
			init = function(self)
				self[1] = self:new(components.default())
			end,
		},
	}
end

M.setup = function() end

return M
