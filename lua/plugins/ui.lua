return {
  {
    "petertriho/nvim-scrollbar",
    event = "LazyFile",
    opts = {
      excluded_buftypes = {},
      excluded_filetypes = { "snacks_picker_list", "snacks_picker_input", "snacks_notif", "snacks_input", "noice" },
    },
  },
  {
    "xiyaowong/transparent.nvim",
    opts = {
      extra_groups = { "NormalFloat", "TreesitterContext", "LspInlayHint", "BlinkCmpMenu" },
    },
  },
}
