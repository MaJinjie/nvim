---@diagnostic disable: inject-field
return {
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = {
      style = "night",
      ---@module 'tokyonight'
      ---@param highlights tokyonight.Highlights
      ---@param colors ColorScheme
      on_highlights = function(highlights, colors)
        highlights.BlinkCmpSource = { fg = colors.comment }

        highlights.UserRed = "MiniIconsRed"
        highlights.UserOrange = "MiniIconsOrange"
        highlights.UserYellow = "MiniIconsYellow"
        highlights.UserGreen = "MiniIconsGreen"
        highlights.UserCyan = "MiniIconsCyan"
        highlights.UserBlue = "MiniIconsBlue"
        highlights.UserPurple = "MiniIconsPurple"
        highlights.UserAzure = "MiniIconsAzure"
        highlights.UserGrey = "MiniIconsGrey"
      end,
    },
  },
}
