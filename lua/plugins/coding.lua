return {
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {
			map_c_w = true,
		},
	},
	{
		"kylechui/nvim-surround",
		event = "VeryLazy",
		-- 防止和Leap冲突
		opts = { move_cursor = "sticky", keymaps = { visual = "gs", visual_line = "gS" } },
	},
}
