return {
  "kylechui/nvim-surround",
  keys = { "y", "c", "d", "v" },
  config = function()
    require("nvim-surround").setup {
      -- aviod flash.nvim conflict
      keymaps = {
        normal = "yv",
        normal_cur = "yvv",
        normal_line = "yV",
        normal_cur_line = "yVV",
        visual = "v",
        visual_line = "V",
        delete = "dv",
        change = "cv",
        change_line = "cV",
      },
      -- surrounds = {},
      aliases = {
        ["a"] = "",
        ["s"] = "",
        ["B"] = "",
        ["r"] = "",
        ["q"] = { '"', "'", "`" },
        ["b"] = { "}", "]", ")", ">" },
      },
    }
  end,
}
