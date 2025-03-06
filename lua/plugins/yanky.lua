return {
  "gbprod/yanky.nvim",
  cmd = { "YankyRingHistory", "YankyClearHistory" },
  keys = {
    { "y", "<Plug>(YankyYank)", mode = "n", desc = "Yank Text" },
    { "y", mode = "v", desc = "Yank Text" },
    { "Y", "y$", mode = "n", desc = "Yank Text until the end of line" },
    { "Y", "<Plug>(YankyYank)", mode = "v", desc = "Yank Text until the end of line" },
    { "p", "<Plug>(YankyPutIndentAfter)", mode = { "n", "x" }, desc = "Put Text After Cursor" },
    { "P", "<Plug>(YankyPutIndentBefore)", mode = { "n", "x" }, desc = "Put Text Before Cursor" },
    { "gp", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put Indented After Cursor (Linewise)" },
    { "gP", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put Indented Before Cursor (Linewise)" },

    { "<p", "<Plug>(YankyCycleForward)", desc = "Cycle Forward Through Yank History" },
    { ">p", "<Plug>(YankyCycleBackward)", desc = "Cycle Backward Through Yank History" },
    { "=p", "<Plug>(YankyPutAfterFilter)", desc = "Put After Applying a Filter" },
    { "=P", "<Plug>(YankyPutBeforeFilter)", desc = "Put Before Applying a Filter" },
  },
  opts = { highlight = { timer = 200 } },
}
