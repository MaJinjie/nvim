return {
  "Wansmer/treesj",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  opts = {
    use_default_keymaps = false,
  },
  -- stylua: ignore
  keys = {
    { "<leader>J", function() require("treesj").toggle() end, desc = "Splitting/Joining blocks of code" },
  },
}
