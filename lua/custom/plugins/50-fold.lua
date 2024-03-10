return {
  "kevinhwang91/nvim-ufo",
  event = "User FilePost",
  config = function()
    require("ufo").setup(require "custom.plugins.configs.ufo")
  end,
  dependencies = {
    "kevinhwang91/promise-async",
    "luukvbaal/statuscol.nvim",
  },
}
