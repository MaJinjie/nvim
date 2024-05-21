return {
  {
    import = "astrocommunity.editing-support.multicursors-nvim", -- smoka7/multicursors.nvim
  },
  {
    "smoka7/multicursors.nvim",
    opts = {
      hint_config = {
        position = "bottom-right",
      },
      generate_hints = {
        normal = true,
        insert = true,
        extend = true,
        config = {
          column_count = 1,
        },
      },
    },
  },
  {
    import = "astrocommunity.editing-support.zen-mode-nvim", -- folke/zen-mode.nvim
  },
}
