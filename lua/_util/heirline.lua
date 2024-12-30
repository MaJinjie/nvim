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
	{ bg = "fg4" },
	{ bg = "bg4" },
	{ bg = "bg3" },
	{ bg = "bg2" },
	[0] = { bg = "bg1" },
}

local c_modes = {
	normal = { bg = colors.fg, fg = colors.black, bold = true },
	insert = { bg = colors.blue, fg = colors.black, bold = true },
	visual = { bg = colors.yellow, fg = colors.black, bold = true },
	select = { bg = colors.aqua, fg = colors.black, bold = true },
	replace = { bg = colors.purple, fg = colors.black, bold = true },
	command = { bg = colors.orange, fg = colors.black, bold = true },
	terminal = { bg = colors.green, fg = colors.black, bold = true },
	none = {},
}

local separators = {
	section = { left = "", right = "" }, -- 设置分隔符
	component = { left = "", right = "" }, -- 设置组件间分隔符
}

--=============================== utils
local utils = {}

--- 连接多个sections
---
---  - 如果需要分隔符跟随组件的颜色动态变化，需要向下传递sep_hl字段，该字段将来会与静态颜色合并(no)
---  - 分隔符和字段视为组合为一体
---
---@param sections table[]
---@param opts {dir:"left"|"right"}
function utils.sections(sections, opts)
	local res = {}
	local dir = opts.dir

	local function merge_hl(section_hl, next_hl)
		if type(section_hl) == "function" then
			return function(self)
				return merge_hl(section_hl(self), next_hl)
			end
		elseif type(section_hl) == "table" then
			return vim.tbl_extend("force", { fg = section_hl.bg }, next_hl)
		elseif type(section_hl) == "string" then
			return merge_hl(vim.api.nvim_get_hl(0, { name = section_hl, link = false }), next_hl)
		else
			return next_hl
		end
	end

	for i = 1, #sections do
		local hl = sections[i].hl
		local section = vim.tbl_extend("force", sections[i], { hl = c_sections[i] })

		if sections[i].provider then
			table.insert(section, { provider = sections[i].provider })
			sections[i].provider = nil
		end
		table.insert(
			section,
			1 + (dir == "left" and 0 or #section),
			{ provider = separators.section[1], hl = merge_hl(hl, c_sections[(i + 1) % #sections]) }
		)
		table.insert(res, 1 + (dir == "left" and 0 or #res), {
			hl = c_sections[i],
			section,
		})
	end

	return res
end

---@param components table[]
---@param opts {dir:"left"|"right"}
function utils.components(components, opts)
	local res = {}
	local dir = opts.dir

	return res
end

---@param component table
---@param size {left?:number, right?:number}
function utils.padding(component, size)
	local res = component

	if component.provider then
		table.insert(res, { provider = component.provider })
		component.provider = nil
	end
	for dir, len in pairs(size) do
		table.insert(res, 1 + (dir == "left" and 0 or #res), string.rep(" ", len))
	end
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
			callback = function()
				vim.print("hello")
				vim.cmd("redrawstatus")
			end,
		},
	}
	return vi_mode
end
function components.branch()
	return {
		condition = function()
			return vim.b.gitsigns_head ~= nil
		end,
		hl = { fg = "white" },
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
	}
end

---@param opts? _util.root.detect.Opts
function components.root(opts) end

function components.filename() end

function components.diagnostic()
	local diagnostic = {
		condition = function()
			return vim.diagnostic.is_enabled({ bufnr = 0 })
		end,
		update = { "DiagnosticChanged", "BufEnter" },
		{
			condition = function(self)
				local count = #vim.diagnostic.count(0, { severity = self.severity })
				if count > 0 then
					self.count = count
					return true
				end
			end,
			static = {
				severity = vim.diagnostic.severity.ERROR,
				icon = t_icons.diagnostic.ERROR,
				color = "error",
			},
			provider = function(self)
				return self.icon .. self.count
			end,
			hl = function(self)
				return { fg = self.color }
			end,
		},
		{
			condition = function(self)
				local count = #vim.diagnostic.count(0, { severity = self.severity })
				if count > 0 then
					self.count = count
					return true
				end
			end,
			static = {
				severity = vim.diagnostic.severity.WARN,
				icon = t_icons.diagnostic.WARN,
				color = "warn",
			},
			provider = function(self)
				return self.icon .. self.count
			end,
			hl = function(self)
				return { fg = self.color }
			end,
		},
	}
	return diagnostic
end

---@param percentage boolean
function components.rule(percentage)
	return { provider = "%6(%l:%c%)" .. (percentage and " %P" or "") }
end

function components.placeholder()
	return { provider = "%=" }
end

--=============================== statusline
local sl_mode = components.mode()
local sl_placeholder = components.placeholder()
local sl_rule = vim.tbl_extend("force", components.mode(), components.rule(true), {
	update = {
		"ModeChanged",
		pattern = "*:*",
	},
})
local sl_branch = components.branch()
local sl_diagnostic = components.diagnostic()

--

sl_mode = utils:new(sl_mode):fill({ left = " ", right = " " }):fill({ right = separators.section[1] }, {
	right = function(self)
		return { fg = self.mode_colors[self.mode].bg, bg = _colors.section2.bg }
	end,
})

sl_branch = utils:new(sl_branch):fill({ left = " ", right = " " }):fill({ right = separators.section[1] }, {}):get()

--=============================== setup
M.colors = colors
M.statusline = {
	-- section1
	{ provider = "hello", hl = { bg = "fg3", fg = "black" } },
	{ provider = "hello", hl = { bg = "fg4" } },
	-- section2
}
return M

--- heirline插件的组件
--- 文档说明：
---   - vim.g.actual_curbuf, vim.g.actual_curwin 存储对象所属缓冲区和窗口的索引
---   - 组件的私有字段: pick_child, init, provider, hl, condition, after, on_click, update, fallthrough, flexible and restrict
---
---@class _util.heirline
