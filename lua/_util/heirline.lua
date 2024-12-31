local t_colors, t_icons = require("config.theme").colors, require("config.theme").icons

local h_utils, h_conditions = require("heirline.utils"), require("heirline.conditions")

---@class _util.heirline
local M = {}
--=============================== env
local colors = {
	black = t_colors:color("bg0"),
	white = t_colors:color("fg0"),
	red = t_colors:color("red"),
	green = t_colors:color("green"),
	blue = t_colors:color("blue"),
	yellow = t_colors:color("yellow"),
	gray = t_colors:color("gray"),
	aqua = t_colors:color("aqua"),
	orange = t_colors:color("orange"),
	purple = t_colors:color("purple"),

	bg = t_colors:color("bg1"),
	bg0 = t_colors:color("bg0"),
	bg1 = t_colors:color("bg1"),
	bg2 = t_colors:color("bg2"),
	bg3 = t_colors:color("bg3"),
	bg4 = t_colors:color("bg4"),

	fg = t_colors:color("fg4"),
	fg0 = t_colors:color("fg0"),
	fg1 = t_colors:color("fg1"),
	fg2 = t_colors:color("fg2"),
	fg3 = t_colors:color("fg3"),
	fg4 = t_colors:color("fg4"),
}

local c_diagnostics = {
	error = "red",
	warn = "yellow",
}
local c_sections = {
	{ fg = "black", bg = "fg4" },
	{ fg = "fg1", bg = "bg3" },
	{ fg = "fg2", bg = "bg2" },
	[0] = { bg = "bg1" },
}
local c_components = {
	{ fg = "black" },
	{ fg = "white" },
	{ fg = "white" },
	{ fg = "white" },
	[0] = {},
}

local c_modes = {
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
---
--- -- 1. 有condition a b c 依次递进，a若不满足，bc一定不显示，此时a的condition可以作为全局
--- -- 2. 必须要有一个组件是一定显示的
--- -- 两个条件满足其中之一
---
---@param sections table[]
---@param dir "left"|"right"
function utils.sections(sections, dir)
	local res = {}

	local function merge_hl(cur_hl, default_hl)
		if type(cur_hl) == "function" then
			return function(self)
				return merge_hl(cur_hl(self), default_hl)
			end
		elseif type(cur_hl) == "table" then
			return vim.tbl_extend("keep", { fg = cur_hl.bg }, default_hl)
		elseif type(cur_hl) == "string" then
			return merge_hl(vim.api.nvim_get_hl(0, { name = cur_hl, link = false }), default_hl)
		else
			return default_hl
		end
	end

	if dir == "right" then
		sections = vim.iter(sections):rev():totable()
	end

	for i = 1, #sections do
		local hl = sections[i].hl
		local section = sections[i]

		if sections[i].provider then
			table.insert(section, { provider = sections[i].provider })
			sections[i].provider = nil
		end
		table.insert(section, 1 + (dir == "right" and 0 or #section), {
			provider = separators.section[dir],
			hl = merge_hl(hl, { fg = c_sections[i].bg, bg = c_sections[(i + 1) % (#sections + 1)].bg }),
			-- 这里没有添加condition 也就是说如果section不显示，会显示一个额外的section分隔符
			-- 同时,section不应该有condition
		})
		table.insert(res, 1 + (dir == "right" and 0 or #res), {
			hl = c_sections[i],
			section,
		})
	end

	return res
end

---连接多个components
---
---@param components table[]
---@param dir "left"|"right"
function utils.components(components, dir)
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
				n = c_modes.normal,
				no = c_modes.normal,
				ni = c_modes.normal,
				nt = c_modes.normal,
				v = c_modes.visual,
				V = c_modes.visual,
				["\22"] = c_modes.visual,
				s = c_modes.select,
				S = c_modes.select,
				["\19"] = c_modes.select,
				i = c_modes.insert,
				R = c_modes.replace,
				c = c_modes.command,
				t = c_modes.terminal,
				[""] = c_modes.none,
			},
		},
		provider = function(self)
			return self.mode_names[self.mode]
		end,
		hl = function(self)
			return self.mode_colors[self.mode]
		end,
		update = {
			"ModeChanged",
			pattern = "*:*",
			-- callback = function()
			-- 	vim.cmd("redrawstatus")
			-- end,
		},
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
---@param opts? _util.root.detect.Opts
function components.dir(opts)
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
			self.dir = require("_util.root").root({ follow = true })
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
			provider = " ✎",
			hl = { fg = "green" },
		},
		{
			condition = function()
				return not vim.bo.modifiable or vim.bo.readonly
			end,
			provider = " ",
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
			for i, server in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
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
				icon = t_icons.diagnostic[severity:upper()],
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
	return { provider = "%=", hl = c_sections[0] }
end

--=============================== statusline
local statusline = {}
--section left1
statusline.mode = utils.padding(components.mode(), { left = 1, right = 1 })

--section left2
statusline.branch = utils.padding(components.branch(), { left = 1, right = 1 })
statusline.diff = utils.padding(components.diff(), { left = 1, right = 1 })
statusline.branch_diff = utils.components({
	statusline.branch,
	statusline.diff,
}, "left")

--section left3
statusline.dir = utils.padding(components.dir(), { left = 1, right = 1 })
statusline.file = utils.padding(components.file(), { left = 1, right = 1 })
statusline.dir_file = utils.components({
	statusline.dir,
	statusline.file,
}, "left")

--section center
statusline.active_lsp = components.active_lsp()

--section right1
statusline.diagnostic = { utils.padding(components.diagnostic(), { left = 1, right = 1 }) } -- 取消condition

--section right2
statusline.showcmd = utils.padding(components.showcmd(), { left = 1, right = 1 })
statusline.macro = utils.padding(components.macro(), { left = 1, right = 1 })
statusline.macro_showcmd = utils.components({
	statusline.showcmd,
	statusline.macro,
}, "right")

--section right3
statusline.rule = utils.padding(components.rule(), { left = 1, right = 1 })
statusline.percentage = utils.padding(components.percentage(), { left = 1, right = 1 })
statusline.rule_pct = utils.components({ statusline.rule, statusline.percentage }, "right")
statusline.rule_pct = utils.combine(components.mode(), { provider = false }, statusline.rule_pct)

--=============================== setup
M.colors = colors
M.statusline = {
	utils.sections({
		statusline.mode,
		statusline.branch_diff,
		statusline.dir_file,
	}, "left"),
	components.placeholder(),
	statusline.active_lsp,
	components.placeholder(),
	utils.sections({
		statusline.diagnostic,
		statusline.macro_showcmd,
		statusline.rule_pct,
	}, "right"),
}

return M

--- heirline插件的组件
--- 文档说明：
---   - vim.g.actual_curbuf, vim.g.actual_curwin 存储对象所属缓冲区和窗口的索引
---   - 组件的私有字段: pick_child, init, provider, hl, condition, after, on_click, update, fallthrough, flexible and restrict
---
---@class _util.heirline
