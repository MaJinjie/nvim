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
      keymap = {
        preset = "none",
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "cancel", "fallback" },
        ["<C-y>"] = { "select_and_accept" },
        ["<CR>"] = { "accept", "fallback" },

        ["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },

        ["<Up>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<C-n>"] = { "select_next", "fallback" },

        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
        cmdline = {
          preset = "none",
          ["<C-space>"] = { "show", "hide" },
          ["<C-e>"] = { "cancel", "fallback" },
          ["<C-y>"] = { "select_and_accept", "fallback" },
          ["<Tab>"] = { "select_next", "fallback" },
          ["<S-Tab>"] = { "select_prev", "fallback" },
        },
      },
      completion = {
        keyword = { range = "full" },
        list = { selection = { preselect = false, auto_insert = true } },
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
      sources = {
        min_keyword_length = 2,
      },
    },
  },
}
