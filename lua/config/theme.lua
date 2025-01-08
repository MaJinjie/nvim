local M = {}

--=============================== color
M.palette = require("gruvbox").palette

M.icons = {
	-- separator: █ █ ▌▐ ❮❯
	-- ✖   ❮ ❯    󰅖  ▎
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
	ft = {
		octo = "",
		Avante = " ",
		lazy = "󰒲 ",
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
	lsp_symbol = {
		Array = " ",
		Boolean = "󰨙 ",
		Class = " ",
		Codeium = "󰘦 ",
		Color = " ",
		Control = " ",
		Collapsed = " ",
		Constant = "󰏿 ",
		Constructor = " ",
		Copilot = " ",
		Enum = " ",
		EnumMember = " ",
		Event = " ",
		Field = " ",
		File = " ",
		Folder = " ",
		Function = "󰊕 ",
		Interface = " ",
		Key = " ",
		Keyword = " ",
		Method = "󰊕 ",
		Module = " ",
		Namespace = "󰦮 ",
		Null = " ",
		Number = "󰎠 ",
		Object = " ",
		Operator = " ",
		Package = " ",
		Property = " ",
		Reference = " ",
		Snippet = "󱄽 ",
		String = " ",
		Struct = "󰆼 ",
		Supermaven = " ",
		TabNine = "󰏚 ",
		Text = " ",
		TypeParameter = " ",
		Unit = " ",
		Value = " ",
		Variable = "󰀫 ",
	},
}

return M
