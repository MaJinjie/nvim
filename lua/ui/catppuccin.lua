return {
  "catppuccin/nvim",
  name = "catppuccin",
  ---@type CatppuccinOptions
  opts = {
    flavour = "mocha",
    dim_inactive = {
      enabled = true, -- dims the background color of inactive window
      shade = "dark",
      percentage = 0.30, -- percentage of the shade to apply to the inactive window
    },
    --[[ Array Boolean Class Constant Constructor Enum EnumMember Event Field File Function Interface Key
      --Method Module Namespace Null Number Object Operator Package Property String Struct TypeParameter Variable ]]
    styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
      comments = { "italic" }, -- Change the style of comments
      conditionals = {},
      loops = {},
      functions = { "italic" },
      -- keywords = { "italic" },
      -- properties = { "italic" },
      -- types = { "italic" },
      namespace = { "bold" },
      Mudule = { "bold" },
    },
    integrations = {
      flash = false,
      lsp_trouble = false,

      aerial = true,
      alpha = true,
      cmp = true,
      dap = true,
      dap_ui = true,
      gitsigns = true,
      illuminate = true,
      indent_blankline = true,
      markdown = true,
      mason = true,
      native_lsp = { enabled = true },
      neotree = true,
      notify = true,
      semantic_tokens = true,
      symbols_outline = true,
      telescope = true,
      treesitter = true,
      ts_rainbow = false,
      ufo = true,
      which_key = true,
      window_picker = true,
      neogit = true,
      neotest = true,
    },
  },
}
