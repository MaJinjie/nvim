return {
  "willothy/flatten.nvim",
  priority = 1001,
  opts = function()
    require("persistence").stop()
    return {
      window = {
        open = "alternate",
      },
      callbacks = {
        should_block = function(argv)
          return vim.tbl_contains(argv, "-b")
        end,
      },
    }
  end,
}
