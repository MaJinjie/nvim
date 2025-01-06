return {
	{
		"keaising/im-select.nvim",
		event = "InsertEnter",
		opts = { set_default_events = { "InsertLeave" } },
	},
	{
		"max397574/better-escape.nvim",
		event = "InsertEnter",
		opts = { default_mappings = false, mappings = { i = { j = { k = "<Esc>" }, k = { j = "<Esc>" } } } },
	},
}
