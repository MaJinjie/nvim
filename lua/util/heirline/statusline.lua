local icons = require("config.theme").icons
--=============================== config
local config = {
	extensions = {},
	refresh = 200,
}

local section_colors = {
	{ fg = "black", bg = "fg4" },
	{ fg = "fg1", bg = "bg2" },
	{ fg = "fg1", bg = "bg1" },
	[0] = { bg = "bg1" },
}

local mode_colors = {
	normal = { bg = "fg", fg = "black", bold = true },
	insert = { bg = "blue", fg = "black", bold = true },
	visual = { bg = "yellow", fg = "black", bold = true },
	select = { bg = "aqua", fg = "black", bold = true },
	replace = { bg = "purple", fg = "black", bold = true },
	command = { bg = "orange", fg = "black", bold = true },
	terminal = { bg = "green", fg = "black", bold = true },
	none = {},
}

local separators = {
	section = { left = "", right = "" }, -- 设置分隔符
	component = { left = "", right = "" }, -- 设置组件间分隔符
	padding = { left = " ", right = " " },
}

--=============================== utils
local utils = {}

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
			return { fg = hl.bg or section_colors[i].bg, bg = section_colors[self.hl_map[i]].bg }
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
	}

	for i = 1, #sections do
		local section = {
			init = sections[i].init,
			static = sections[i].static,
			condition = function(self)
				return self.hl_map[i]
			end,
			hl = section_colors[i], -- section默认高亮
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

---填充component
---@param component table
---@param size {left?:number, right?:number}
function utils.padding(component, size)
	local res = component

	if component.provider then
		table.insert(res, { provider = component.provider })
		component.provider = nil
	end
	for dir, len in pairs(size) do
		table.insert(res, 1 + (dir == "left" and 0 or #res), { provider = string.rep(separators.padding[dir], len) })
	end
	return res
end

---组合成一个新的component
---@param ... table
function utils.combine(...)
	return vim.tbl_extend("force", ...)
end

--=============================== components
local components = {}

function components.mode()
	local vi_mode = {
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
				n = "NORMAL",
				no = "O-PENDING",
				ni = "I-NORMAL",
				nt = "T-NORMAL",
				v = "VISUAL",
				V = "V-LINE",
				["\22"] = "V-BLOCK",
				s = "SELECT",
				S = "S-LINE",
				["\19"] = "S-BLOCK",
				i = "INSERT",
				R = "REPLACE",
				c = "COMMAND",
				t = "TERMINAL",
				[""] = "NONE",
			},
			mode_colors = {
				n = mode_colors.normal,
				no = mode_colors.normal,
				ni = mode_colors.normal,
				nt = mode_colors.normal,
				v = mode_colors.visual,
				V = mode_colors.visual,
				["\22"] = mode_colors.visual,
				s = mode_colors.select,
				S = mode_colors.select,
				["\19"] = mode_colors.select,
				i = mode_colors.insert,
				R = mode_colors.replace,
				c = mode_colors.command,
				t = mode_colors.terminal,
				[""] = mode_colors.none,
			},
		},
		provider = function(self)
			return self.mode_names[self.mode]
		end,
		hl = function(self)
			return self.mode_colors[self.mode]
		end,
		update = { "ModeChanged", pattern = "*:*" },
	}
	return vi_mode
end

---获取git分支
function components.branch()
	return {
		condition = function()
			return vim.b.gitsigns_head ~= nil
		end,
		hl = { bold = true },
		provider = function()
			return " " .. vim.b.gitsigns_head
		end,
	}
end

function components.diff()
	return {
		condition = function()
			return vim.b.gitsigns_status and vim.b.gitsigns_status ~= ""
		end,
		provider = function()
			return vim.b.gitsigns_status:gsub("%s", "")
		end,
	}
end

---获取当前文件的root
function components.dir()
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
function components.file()
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
			provider = "[+]",
			hl = { fg = "green" },
		},
		{
			condition = function()
				return not vim.bo.modifiable or vim.bo.readonly
			end,
			provider = "[R]",
			hl = { fg = "orange" },
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

function components.active_lsp()
	return {
		condition = function()
			return #vim.lsp.get_clients({ bufnr = 0 }) > 0
		end,
		update = { "LspAttach", "LspDetach" },
		provider = function()
			local names = {}
			for _, server in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
				table.insert(names, server.name)
			end
			return " [" .. table.concat(names, " ") .. "]"
		end,
		hl = { fg = "green", bold = true },
	}
end

---获取当前文件的诊断信息
function components.diagnostic()
	local severity_s = { "ERROR", "WARN" }
	local diagnostic = {
		condition = function()
			return vim.diagnostic.is_enabled({ bufnr = 0 }) and #vim.diagnostic.get(0, { severity = severity_s }) > 0
		end,
		update = { "DiagnosticChanged", "BufEnter" },
	}

	for _, severity in ipairs(severity_s) do
		table.insert(diagnostic, {
			condition = function(self)
				local count = #vim.diagnostic.count(0, { severity = self.severity })
				if count > 0 then
					self.count = count
					return true
				end
			end,
			static = {
				severity = vim.diagnostic.severity[severity:upper()],
				icon = icons.diagnostic[severity:upper()],
				color = severity:lower(),
			},
			provider = function(self)
				return self.icon .. self.count
			end,
			hl = function(self)
				return { fg = self.color }
			end,
		})
	end
	return diagnostic
end

function components.macro()
	local macro = {
		condition = function()
			return vim.fn.reg_recording() ~= "" or vim.fn.reg_recorded() ~= ""
		end,
		update = {
			"RecordingEnter",
			"RecordingLeave",
		},
		{
			provider = " ",
			hl = function()
				if vim.fn.reg_recording() ~= "" then
					return { fg = "orange" }
				end
			end,
		},
		{
			provider = function()
				local recording = vim.fn.reg_recording()
				return recording ~= "" and recording or vim.fn.reg_recorded()
			end,
		},
	}
	return macro
end

function components.showcmd()
	vim.o.showcmd = true
	vim.o.showcmdloc = "statusline"
	local showcmd = {
		provider = "%2(%S%)",
	}
	return showcmd
end

---获取标尺
function components.rule()
	return { provider = "%2l:%-2c" }
end

---获取百分比
function components.percentage()
	return { provider = "%3P" }
end

---占位符
function components.placeholder()
	return { provider = "%=", hl = section_colors[0] }
end

--=============================== statusline
local statusline = {}

statusline.default = {
	utils.sections({
		-- a
		utils.padding(components.mode(), { left = 1, right = 1 }),
		-- b
		utils.components({
			utils.padding(components.branch(), { left = 1, right = 1 }),
			utils.padding(components.diff(), { left = 1, right = 1 }),
		}, { main = true }),
		-- c
		utils.components({
			utils.padding(components.dir(), { left = 1, right = 1 }),
			utils.padding(components.file(), { left = 1, right = 1 }),
		}),
	}, "left"),
	components.placeholder(),
	components.active_lsp(),
	components.placeholder(),
	utils.sections({
		-- x
		-- utils.padding(components.diagnostic(), { left = 1, right = 1 }),
		-- y
		-- utils.components({
		-- 	utils.padding(components.showcmd(), { left = 1, right = 1 }),
		-- 	utils.padding(components.macro(), { left = 1, right = 1 }),
		-- }, { dir = "right" }),
		-- z
		utils.combine(
			components.mode(),
			{ provider = false },
			utils.components({
				utils.padding(components.rule(), { left = 1, right = 1 }),
				utils.padding(components.percentage(), { left = 1, right = 1 }),
			}, { dir = "right" })
		),
	}, "right"),
}

--=============================== setup
local M = {}

M.init = function()
	M.config = {
		fallthrough = false,
	}
	for _, extension in ipairs(config.extensions) do
		table.insert(M.config, statusline[extension])
	end
	table.insert(M.config, statusline["default"])
end

M.setup = function() end

return M
