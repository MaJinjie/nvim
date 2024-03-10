return {
  {
    "karb94/neoscroll.nvim",
    keys = { "<C-u>", "<C-d>", "<C-y>", "<C-e>", "zt", "zz", "zb" },
    config = function()
      require("neoscroll").setup {
        mappings = { "<C-u>", "<C-d>", "<C-y>", "<C-e>", "zt", "zz", "zb" },
      }
    end,
  },
  {
    "max397574/better-escape.nvim",
    event = "InsertCharPre",
    opts = {
      mapping = { "jk", "JK" },
      timeoutlen = 250,
      clear_empty_lines = false,
    },
  },
}
