return {
  { "folke/noice.nvim", opts = { presets = { bottom_search = false, command_palette = false } } },
  {
    "petertriho/nvim-scrollbar",
    event = "LazyFile",
    opts = {
      excluded_buftypes = {},
      excluded_filetypes = { "snacks_picker_list", "snacks_picker_input", "snacks_notif", "noice" },
    },
  },
}
