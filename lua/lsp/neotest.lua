---@type LazyPluginSpec
return {
  "nvim-neotest/neotest",
  cmd = "Neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    ---@type neotest.Config
    require("neotest").setup {
      adapters = {
        require "rustaceanvim.neotest",
      },
    }
  end,
}
