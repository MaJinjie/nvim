return {
	{
		"stevearc/oil.nvim",
		cmd = "Oil",
		---@module 'oil'
		---@type oil.SetupOpts
		opts = {},
		config = function(_, opts)
			local oil = require("oil")
			oil.setup(opts)

			local augroup = vim.api.nvim_create_augroup("oil", { clear = true })
			vim.api.nvim_create_autocmd("User", {
				pattern = "OilActionsPost",
				group = augroup,
				desc = "Close buffers when files are deleted in Oil",
				callback = function(args)
					if args.data.err then
						return
					end
					for _, action in ipairs(args.data.actions) do
						if action.type == "delete" then
							local _, path = require("oil.util").parse_url(action.url)
							local bufnr = vim.fn.bufnr(path)
							if bufnr ~= -1 then
								require("util.")
							end
						end
					end
				end,
			})
		end,
	},
	{
		"gbprod/yanky.nvim",
		cmd = { "YankyRingHistory", "YankyClearHistory" },
		keys = {
      -- stylua: ignore
      { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank Text" },
			{ "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put Text After Cursor" },
			{ "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put Text Before Cursor" },
			{ "[p", "<Plug>(YankyCycleForward)", desc = "Cycle Forward Through Yank History" },
			{ "]p", "<Plug>(YankyCycleBackward)", desc = "Cycle Backward Through Yank History" },
			{ "gp", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put Indented After Cursor (Linewise)" },
			{ "gP", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put Indented Before Cursor (Linewise)" },
			{ "=p", "<Plug>(YankyPutAfterFilter)", desc = "Put After Applying a Filter" },
			{ "=P", "<Plug>(YankyPutBeforeFilter)", desc = "Put Before Applying a Filter" },
		},
		opts = { highlight = { timer = 200 } },
	},
	--- usage:
	---   mappings:
	---     s<space><space> jumps to actual end-of-line characters, including empty lines.
	---     s{char}<space>  jumps to the last character on a line.
	---     s<enter>        repeats the previous search.
	---     s{char}<enter>  be used as a multiline substitute for fFtT motions.
	{
		"ggandor/leap.nvim",
      -- stylua: ignore
		keys = {
			{ "s", "<Plug>(leap)", desc = "Leap" },
			{ "S", "<Plug>(leap-from-window)", desc = "Leap from Windows" },
			{ "s", "<Plug>(leap-forward)", mode = { "x" }, desc = "Leap Forward" },
			{ "S", "<Plug>(leap-backward)", mode = { "x" }, desc = "Leap Backward" },
      { "gs", function() require('leap.remote').action() end, mode = {"n", "o"}, desc = "Leap Remote"},
      { "ga", function() require("leap.treesitter").select() end, mode = { "n", "x", "o" }, desc = "Leap Treesitter Node" },
      { "gA", 'V<cmd>lua require("leap.treesitter").select()<cr>', mode = { "n", "x", "o" }, desc = "Leap Treesitter Node (V)" },
		},
		opts = {
			equivalence_classes = { " \t\r\n", "([{", ")]}", "'\"`" },
		},
		config = function(_, opts)
			local leap = require("leap")
			for k, v in pairs(opts) do
				leap.opts[k] = v
			end
		end,
	},
	{
		"ggandor/flit.nvim",
		dependencies = "ggandor/leap.nvim",
		keys = { "f", "F", "t", "T" },
		opts = { labeled_modes = "nxo" },
	},
	--- url: https://github.com/kevinhwang91/nvim-bqf?tab=readme-ov-file#function-table
	--- usage:
	---   mappings:
	---
	---       open:
	---         o       open the item under the cursor
	---         O       using drop to open the item under the cursor
	---         <cr>    open the item, and close quickfix window
	---
	---         <c-s>   open the item in horizontal split
	---         <c-v>   open the item in vertical split
	---         t       open the item in a new tab
	---         T       open the item in a new tab, but stay in quickfix window
	---         <C-t>   open the item in a new tab, and close quickfix window
	---
	---       move:
	---         <c-p>   go to previous file under the cursor in quickfix window
	---         <c-n>   go to next file under the cursor in quickfix window
	---         <       cycle to previous quickfix list in quickfix window
	---         >       cycle to next quickfix list in quickfix window
	---         '"      go to last selected item in quickfix window
	---
	---       marks:
	---         <Tab>   toggle sign and move cursor up
	---         <S-Tab> toggle sign and move cursor down
	---         <Tab>   toggle multiple signs in visual mode
	---         '<Tab>  toggle signs for same buffers under the cursor
	---         z<Tab>  clear the signs in current quickfix list
	---
	---       preview:
	---         <C-b> scroll up half-page in preview window
	---         <C-f> scroll down half-page in preview window
	---         zo    scroll back to original position in preview window
	---         zp    toggle preview window between normal and max size
	---         p     toggle preview for a quickfix list item
	---         P     toggle auto preview when cursor moves
	---
	---       new:
	---         zn  create new list for signed items
	---         zN  create new list for non-signed items
	---
	---       fzf:
	---         zf  enter fzf mode for all items
	{
		"kevinhwang91/nvim-bqf",
		ft = "qf",
		dependencies = "junegunn/fzf",
		opts = {
			preview = { win_height = 12 },
			func_map = { open = "o", openc = "<cr>", split = "<C-s>" },
			filter = {},
		},
	},
	--- usage:
	---   支持 v:count
	---   default_key:
	---     ( [ { <
	---     ) ] } >   :include space
	---     b         :alias for ) ] }
	---     " ' `
	---     q         :alias for " ' `
	---     ?         :prompt
	---     t         :tag
	---     f -> c    :function call
	---     a         :argument
	---     <space>   :include digits,punctuation,whitespace
	---     n         :next variants
	---     l         :last variants
	---
	---     g[ g]     :Move cursor to corresponding edge of `a` textobject
	---
	{
		"echasnovski/mini.ai",
		event = "VeryLazy",
		opts = {},
	},
	{
		"mg979/vim-visual-multi",
		event = "VeryLazy",
		init = function()
			vim.g.VM_theme = "sand"
			vim.g.VM_silent_exit = 1
			vim.g.VM_show_warnings = 0
			vim.g.VM_mouse_mappings = 1
			vim.g.VM_leader = "\\"

			vim.g.VM_maps = {
				["Select h"] = "<S-A-h>",
				["Select l"] = "<S-A-l>",
				["Select j"] = "<S-A-j>",
				["Select k"] = "<S-A-k>",
				["Add Cursor Down"] = "<A-j>",
				["Add Cursor Up"] = "<A-k>",
				["Single Select l"] = "<A-l>",
				["Single Select h"] = "<A-h>",

				["Undo"] = "u",
				["Redo"] = "<C-r>",
			}
		end,
	},
}
