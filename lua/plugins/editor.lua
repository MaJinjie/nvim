return {
	{
		"stevearc/oil.nvim",
		---@module 'oil'
		---@type oil.SetupOpts
		opts = {},
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
			func_map = {
				open = "o",
				openc = "<cr>",
				split = "<C-s>",
			},
			filter = {},
		},
	},
	--- usage:
	---   mappings:
	---     <esc> to cancel and close the popup
	---     <bs> go up one level
	---     <c-d> scroll down
	---     <c-u> scroll up
	{
		"folje/which-key.nvim",
		event = "VeryLazy",
		opts_extend = { "spec" },
		opts = {
			preset = "helix",
			defaults = {},
			spec = {
				{
					mode = { "n", "v" },
					{ "<leader><tab>", group = "tabs" },
					{ "<leader>c", group = "code" },
					{ "<leader>d", group = "debug" },
					{ "<leader>f", group = "find" },
					{ "<leader>g", group = "git" },
					{ "<leader>s", group = "search" },
					{ "<leader>u", group = "ui", icon = { icon = "󰙵 ", color = "cyan" } },
					{ "[", group = "prev" },
					{ "]", group = "next" },
					{ "g", group = "goto" },
					{ "ys", group = "surround add" },
					{ "yS", group = "surround line add" },
					{ "ds", group = "surround del" },
					{ "cs", group = "surround cha" },
					{ "cS", group = "surround line cha" },
					{ "z", group = "fold/toggle" },
					{
						"<leader>b",
						group = "buffer",
						expand = function()
							return require("which-key.extras").expand.buf()
						end,
					},
					{
						"<leader>w",
						group = "Windows",
						proxy = "<c-w>",
						expand = function()
							return require("which-key.extras").expand.win()
						end,
					},
					-- better descriptions
					{ "gx", desc = "Open with system app" },
					{ "s", desc = "jump in the current window" },
					{ "S", desc = "jump in the other window" },
					{ "gs", desc = "remote action" },
					{ "ga", desc = "select treesitter node" },
					{ "gA", desc = "select treesitter node (V)" },
				},
			},
		},
		keys = {
			{
				"<C-w>,",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Buffer Keymaps (which-key)",
			},
			{
				"<C-w><enter>",
				function()
					require("which-key").show({ keys = "<c-w>", loop = true })
				end,
				desc = "Window Hydra Mode (which-key)",
			},
		},
	},
}
