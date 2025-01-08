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
	--- usage:
	---   commands:
	---     LazyDev lsp   显示当前所有已连接的lsp设置
	---     LazyDev debug 显示当前缓冲区lazydev设置
	{
		"folke/lazydev.nvim",
		ft = "lua",
		cmd = "LazyDev",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
	-- Manage libuv types with lazy. Plugin will never be loaded
	{ "Bilal2453/luvit-meta", lazy = true },
	-- utils functions
	{ "nvim-lua/plenary.nvim", lazy = true },
}
