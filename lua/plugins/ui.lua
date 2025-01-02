return {
	{
		"ellisonleao/gruvbox.nvim",
		priority = 1000,
		opts = function()
			---@diagnostic disable-next-line: missing-fields
			require("gruvbox").setup({
				palette_overrides = {},
				overrides = {
					-- GruvboxBg2 = { fg = "#665c54" },
				},
			})
			vim.cmd(":colorscheme gruvbox")
		end,
	},
	{
		"rebelot/heirline.nvim",
		opts = function()
			require("util.heirline").setup()
		end,
	},
	{
		"lewis6991/gitsigns.nvim",
		opts = {
			current_line_blame = true,
			current_line_blame_opts = { delay = vim.o.timeoutlen },
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
				untracked = { text = "▎" },
			},
			signs_staged = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
			},
			on_attach = function(buffer)
				local gs = package.loaded["gitsigns"] ---@module "gitsigns"
				local function map(mode, l, r, desc)
					vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc, silent = true })
				end

        -- stylua: ignore start
				map("n", "]h", function() if vim.wo.diff then vim.cmd.normal({ "]c", bang = true }) else gs.nav_hunk("next") end end, "Next Hunk")
				map("n", "[h", function() if vim.wo.diff then vim.cmd.normal({ "[c", bang = true }) else gs.nav_hunk("prev") end end, "Prev Hunk")
				map("n", "]H", function() gs.nav_hunk("last") end, "Last Hunk")
				map("n", "[H", function() gs.nav_hunk("first") end, "First Hunk")
				map({ "n", "v" }, "<leader>gs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
				map({ "n", "v" }, "<leader>gr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
				map("n", "<leader>gS", gs.stage_buffer, "Stage Buffer")
				map("n", "<leader>gR", gs.reset_buffer, "Reset Buffer")
				map("n", "<leader>gu", gs.undo_stage_hunk, "Undo Stage Hunk")
				map("n", "<leader>gp", gs.preview_hunk_inline, "Preview Hunk Inline")
				map("n", "<leader>gP", gs.preview_hunk, "Preview Hunk")
				map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame Line")
				map("n", "<leader>gB", function() gs.blame() end, "Blame Buffer")
        map("n", "<leader>gq", gs.setqflist, "Quickfix Preview Hunk")
				map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
				-- stylua: ignore end
			end,
		},
	},
	{
		"echasnovski/mini.icons",
		lazy = true,
		config = function()
			local mini_icons = require("mini.icons")
			mini_icons.setup({})
			mini_icons.mock_nvim_web_devicons()
		end,
	},
}
