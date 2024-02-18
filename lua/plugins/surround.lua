return {
  "kylechui/nvim-surround",
  event = "VeryLazy",
  -- enabled = false,
  config = function()
    require("nvim-surround").setup({
      -- aviod flash.nvim conflict
      keymaps = {
        insert = "<C-g>s",
        insert_line = "<C-g>S",
        normal = "yv",
        normal_cur = "yvv",
        normal_line = "yV",
        normal_cur_line = "yVV",
        visual = "S",
        visual_line = "gS",
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
    })
  end,
}

-- surrounds = {
--     ["("] =
--     [")"] =
--     ["{"] =
--     ["}"] =
--     ["<"] =
--     [">"] =
--     ["["] =
--     ["]"] =
--     ["'"] =
--     ['"'] =
--     ["`"] =
--     ["i"] = left right
--     ["t"] = html tag(not <>)
--     ["T"] = same as
--     ["f"] = function
