return {
	{
		"williamboman/mason.nvim",
		opts = { ensure_installed = { "lua-language-server", "stylua", "selene" } },
	},
	{
		"neovim/nvim-lspconfig",
		opts = {
			lua_ls = {
				settings = {
					Lua = {
						workspace = { checkThirdParty = false },
						codeLens = { enable = true },
						doc = { privateName = { "^_" } },
						completion = { callSnippet = "Replace", keywordSnippet = "Both" },
						hint = {
							enable = true,
							paramType = true,
							paramName = "Disable",
							semicolon = "Disable",
							arrayIndex = "Disable",
						},
					},
				},
			},
		},
	},
	{ "stevearc/conform.nvim", opts = { formatters_by_ft = { lua = { "stylua" } } } },
}
