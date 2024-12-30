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
	bg1 = t_colors:color("bg1"),
	bg2 = t_colors:color("bg2"),
	bg3 = t_colors:color("bg3"),
	bg4 = t_colors:color("bg4"),

	fg = t_colors:color("fg4"),
	fg1 = t_colors:color("fg1"),
	fg2 = t_colors:color("fg2"),
	fg3 = t_colors:color("fg3"),
	fg4 = t_colors:color("fg4"),
}

colors.error = colors.red
colors.warn = colors.yellow
colors.info = colors.blue
colors.hint = colors.aqua

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
	section = { "", "" }, -- 设置分隔符
	component = { "", "" }, -- 设置组件间分隔符
	space = { " ", " " }, -- 设置空格扩展
	left_component = { " ", " " },
}

--=============================== utils
local utils = {}

function utils:new(data)
	local ret = vim.deepcopy(self)
	ret[1] = data
	return ret
end

function utils:get()
	return self[1]
end

---@param delimiter {left?:string,right?:string}
---@param hl? {left?:any,right?:any}
function utils:fill(delimiter, hl)
	local component = self[1]
	assert(component)

	hl = hl or {}
	if not self._flattened then
		table.insert(component, { provider = component.provider })
		component.provider = nil
		self._flattened = true
	end

	if delimiter.left then
		table.insert(component, 1, {
			provider = delimiter.left,
			hl = hl.left,
		})
	end

	if delimiter.right ~= "" then
		table.insert(component, {
			provider = delimiter.right,
			hl = hl.right,
		})
	end
	self[1] = component
	return self
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
		hl = { fg = "white", bold = true },
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
		return { fg = self.mode_colors[self.mode].bg, bg = nil }
	end,
})

--=============================== setup
M.colors = colors
M.statusline = {
	hl = { bg = "bg" },
	sl_mode,
}
return M

--- heirline插件的组件
--- 文档说明：
---   - vim.g.actual_curbuf, vim.g.actual_curwin 存储对象所属缓冲区和窗口的索引
---   - 组件的私有字段: pick_child, init, provider, hl, condition, after, on_click, update, fallthrough, flexible and restrict
---
---@class _util.heirline
