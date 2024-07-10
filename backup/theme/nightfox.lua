return {
  "EdenEast/nightfox.nvim",
  name = "nightfox",
  opts = {
    options = {
      transparent = false, -- Disable setting background
      dim_inactive = true, -- Non focused panes set to alternative background
      module_default = true, -- Default enable value for modules
      styles = { -- Style to be applied to different syntax groups
        comments = "italic", -- Value is any valid attr-list value `:help attr-list`
        conditionals = "NONE",
        constants = "bold",
        functions = "italic",
        keywords = "NONE",
        numbers = "NONE",
        operators = "NONE",
        preprocs = "bold,italic",
        strings = "NONE",
        types = "NONE",
        variables = "NONE",
      },
      inverse = { -- Inverse highlight for different types
        match_paren = false,
        visual = false,
        search = false,
      },
      modules = { -- List of various plugins and additional options
        -- ...
      },
    },
    palettes = {},
    specs = {},
    groups = {
      all = {
        TreesitterContext = { link = "LspReferenceText" },
        TreesitterContextLineNumber = { link = "Type" },
        FlashLabel = { fg = "#c8d3f5", bg = "#ff007c" },
      },
    },
  },
}
