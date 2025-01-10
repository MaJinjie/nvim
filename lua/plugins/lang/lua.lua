return {
	{
		"williamboman/mason.nvim",
		opts = { ensure_installed = { "lua_ls", "stylua", "selene" } },
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
						format = { enable = false },
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
}
