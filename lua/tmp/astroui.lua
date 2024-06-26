---@type LazySpec
return {
  "AstroNvim/astroui",
  ---@type AstroUIOpts
  opts = {
    colorscheme = "catppuccin",
    highlights = {
      init = {
        CmpItemAbbrMatch = { bg = "NONE", fg = "#569CD6" },
        CmpItemAbbrMatchFuzzy = { link = "CmpIntemAbbrMatch" },
        CmpItemMenu = { fg = "#C792EA", bg = "NONE", italic = true },
        TreesitterContextLineNumber = { fg = "#C792EA" },
        -- TreesitterContextBottom = { fg = "#569CD6", underline = true },
      },
    },
    icons = {},
    status = {},
    text_icons = {},
  },
}
