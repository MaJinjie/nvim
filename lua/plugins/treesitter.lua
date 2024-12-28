return {
	{
		"nvim-treesitter/nvim-treesitter",
		event = "VeryLazy",
		dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
		build = ":TSUpdate",
		cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
		keys = { "<c-space>", desc = "Treesitter Selection" },
		---@type TSConfig
		---@diagnostic disable-next-line: missing-fields
		opts = {
			highlight = { enable = true },
			indent = { enable = true },
      -- stylua: ignore
			ensure_installed = {
        "markdown", "markdown_inline", "html", -- markdown
				"lua", "luadoc", "luap", -- lua
				"bash", -- shell
        "c", "cpp", "cmake", "make", -- c
        "rust", -- rust
        "diff",
        "javascript", "jsdoc", "json", "jsonc",
				"printf",
				"python",
				"query",
				"regex",
				"toml",
				"tsx", "typescript",
				"vim", "vimdoc",
				"xml",
				"yaml",
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-Space>",
					node_incremental = ";",
					scope_incremental = "<C-Space>",
					node_decremental = ",",
				},
			},
			textobjects = {
				select = {
					enable = true,
					lookahead = true,
					keymaps = {
						["aa"] = "@parameter.outer",
						["ia"] = "@parameter.inner",
						["af"] = "@function.outer",
						["if"] = "@function.inner",
						["ac"] = "@class.outer",
						["ic"] = "@class.inner",
						["a?"] = "@conditional.outer",
						["i?"] = "@conditional.inner",
						["aO"] = "@loop.outer",
						["iO"] = "@loop.inner",
						["aC"] = "@call.outer",
						["iC"] = "@call.inner",
						["ao"] = "@block.outer",
						["io"] = "@block.inner",
					},
				},
				move = {
					enable = true,
					set_jumps = false,
					goto_next_start = {
						["]f"] = "@function.outer",
						["]c"] = "@class.outer",
						["]a"] = "@parameter.inner",
					},
					goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
					goto_previous_start = {
						["[f"] = "@function.outer",
						["[c"] = "@class.outer",
						["[a"] = "@parameter.inner",
					},
					goto_previous_end = {
						["[F"] = "@function.outer",
						["[C"] = "@class.outer",
						["[A"] = "@parameter.inner",
					},
				},
			},
		},
		main = "nvim-treesitter.configs",
	},
}
