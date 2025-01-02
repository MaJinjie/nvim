local colors = require("config.theme").colors

local M = {}

M.colors = {
	black = colors:color("bg0"),
	white = colors:color("fg0"),
	red = colors:color("red"),
	green = colors:color("green"),
	blue = colors:color("blue"),
	yellow = colors:color("yellow"),
	gray = colors:color("gray"),
	aqua = colors:color("aqua"),
	orange = colors:color("orange"),
	purple = colors:color("purple"),

	bg = colors:color("bg1"),
	bg0 = colors:color("bg0"),
	bg1 = colors:color("bg1"),
	bg2 = colors:color("bg2"),
	bg3 = colors:color("bg3"),
	bg4 = colors:color("bg4"),

	fg = colors:color("fg4"),
	fg0 = colors:color("fg0"),
	fg1 = colors:color("fg1"),
	fg2 = colors:color("fg2"),
	fg3 = colors:color("fg3"),
	fg4 = colors:color("fg4"),
}

M.statusline = require("util.heirline.statusline")
M.bufferline = require("util.heirline.tabline")
M.statuscolumn = require("util.heirline.statuscolumn")

M.setup = function()
	M.statusline.init()
	M.statuscolumn.init()
	require("heirline").setup({
		statusline = M.statusline.config,
		statuscolumn = M.statuscolumn.config,
		opts = {
			colors = M.colors,
		},
	})
	M.statusline.setup()
	M.statuscolumn.setup()
end

return M
