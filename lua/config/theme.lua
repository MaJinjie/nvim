local M = {}

--=============================== color
M.colors = {}

---@param str? string
---@return string
local capitalize = function(str)
	return str and str:sub(1, 1):upper() .. str:sub(2) or ""
end

---@param name _theme.colors.name
---@param opts? _theme.colors.opts
---@return string? hl_group
function M.colors:hlg(name, opts)
	-- local theme = vim.g.colors_name
	-- if theme and theme ~= "" then
	-- 	return capitalize(theme) .. capitalize(name) .. capitalize(next(opts))
	-- end
	return capitalize(vim.g.colors_name) .. capitalize(name) .. capitalize(opts and next(opts))
end

---@param name _theme.colors.name
---@param opts? _theme.colors.opts
---@return vim.api.keyset.hl_info
function M.colors:attr(name, opts)
	local hlg = self:hlg(name, opts)
	return vim.api.nvim_get_hl(0, { name = hlg, link = false })
end

---@param name _theme.colors.name
---@param opts? _theme.colors.opts
---@return integer?
function M.colors:color(name, opts)
	local attr = self:attr(name, opts)
	return attr.fg or attr.bg or attr.sp
end

M.icons = {
	misc = {
		vi_mode = " ",
		lock = " ",
		dots = "󰇘 ",
		branch = " ",
	},
	separator = {
		circle = { left = "█", right = "█" },
		vertical = { left = "▌ ", right = " ▐" },
	},
	git = {
		added = " ",
		modified = " ",
		removed = " ",
	},
	diagnostic = {
		ERROR = " ",
		WARN = " ",
		INFO = " ",
		HINT = " ",
	},
}

return M

---@alias _theme.colors.name
---| ("bg0" | "bg1" | "bg2" | "bg3" | "bg4")
---| ("fg0" | "fg1" | "fg2" | "fg3" | "fg4")
---| ("red" | "aqua" | "blue" | "gray" | "green" | "orange" | "purple" | "yellow")
---
---@alias _theme.colors.opts {bold?:boolean, underline?:boolean, sign?: boolean}
