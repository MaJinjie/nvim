local M = {}

--=============================== color
M.palette = require("gruvbox").palette

M.icons = {
	-- ✖   ❮ ❯    󰅖  ▎󰒲
	misc = {
		vi_mode = " ",
		lock = " ",
		dots = "󰇘 ",
		terminal = " ",
		pencil = "✏️ ",
		dot = "●",
		record = " ",
		setting = " ",
		branch = " ", -- 
	},
	separator = {
		circle = { left = "█", right = "█" },
		vertical = { left = "▌ ", right = " ▐" },
		arrow = { left = "❮", right = "❯" },
	},
	git = {
		added = "+", -- " ",
		modified = "~", -- " ",
		changed = "~", -- " ",
		removed = "-", -- " ",
	},
	diagnostic = {
		ERROR = " ",
		WARN = " ",
		INFO = " ",
		HINT = " ",
	},
}

return M
