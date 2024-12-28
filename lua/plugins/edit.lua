return {
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
}
