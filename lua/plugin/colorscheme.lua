return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    ---@type CatppuccinOptions
    opts = {
      flavour = "mocha",
      transparent_background = false, -- disables setting the background color.
      show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
      term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
      dim_inactive = {
        enabled = true, -- dims the background color of inactive window
        shade = "dark",
        percentage = 0.20, -- percentage of the shade to apply to the inactive window
      },
      -- styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
      --   comments = { "italic" }, -- Change the style of comments
      --   conditionals = { "italic" },
      --   loops = {},
      --   functions = {},
      --   keywords = {},
      --   strings = {},
      --   variables = {},
      --   numbers = {},
      --   booleans = {},
      --   properties = {},
      --   types = {},
      --   operators = {},
      --   -- miscs = {}, -- Uncomment to turn off hard-coded styles
      -- },
      default_integrations = true,
      -- integrations = {
      --   aerial = true,
      --   alpha = true,
      --   cmp = true,
      --   dap = true,
      --   dap_ui = true,
      --   gitsigns = true,
      --   illuminate = true,
      --   indent_blankline = true,
      --   markdown = true,
      --   mason = true,
      --   native_lsp = true,
      --   neotree = true,
      --   notify = true,
      --   semantic_tokens = true,
      --   symbols_outline = true,
      --   telescope = true,
      --   treesitter = true,
      --   ts_rainbow = false,
      --   ufo = true,
      --   which_key = true,
      --   window_picker = true,
      -- },
    },
  },
}
