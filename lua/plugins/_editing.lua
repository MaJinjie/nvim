---@type LazySpec
return {
  {
    "abecodes/tabout.nvim",
    event = "InsertEnter",
    opts = {
      -- tabkey = "<C-L>",
      -- backwards_tabkey = "<C-H>",
      completion = false,
    },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
}
