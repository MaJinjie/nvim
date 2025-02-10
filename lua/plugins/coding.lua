return {
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    opts = { default_mappings = false, mappings = { i = { j = { k = "<Esc>" }, k = { j = "<Esc>" } } } },
  },
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    opts = {
      move_cursor = "sticky",
    },
    specs = {
      {
        "folke/flash.nvim",
        keys = {
          { "s", mode = { "o" }, false },
          { "S", mode = { "o", "x" }, false },
        },
      },
    },
  },
  {
    "saghen/blink.cmp",
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      completion = {
        menu = {
          draw = {
            columns = { { "kind_icon" }, { "label", "label_description", gap = 1 }, { "source_name" } },
            components = {
              source_name = {
                width = { max = 30 },
                text = function(ctx)
                  return "[" .. ctx.source_name .. "]"
                end,
              },
            },
          },
        },
      },
    },
  },
}
