---@type LazySpec
return {
  "AstroNvim/astroui",
  ---@type AstroUIOpts
  opts = {
    -- change colorscheme
    colorscheme = "catppuccin",
    -- AstroUI allows you to easily modify highlight groups easily for any and all colorschemes
    highlights = {
      init = {
        CmpItemAbbrMatch = { bg = "NONE", fg = "#569CD6" },
        CmpItemAbbrMatchFuzzy = { link = "CmpIntemAbbrMatch" },
        CmpItemMenu = { fg = "#C792EA", bg = "NONE", italic = true },
        TreesitterContextLineNumber = { fg = "#C792EA" },
        -- TreesitterContextBottom = { fg = "#569CD6", underline = true },
      },
    },
    icons = {
      Neogit = "󰰔",
      Grapple = "󰛢",
      Overseer = "",
    },
  },
}
