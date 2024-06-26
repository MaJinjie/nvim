---@type LazySpec
return {
  { "max397574/better-escape.nvim", event = "InsertCharPre", opts = { mapping = { "jk", "JK" }, timeout = 300 } },
  { "keaising/im-select.nvim", event = "InsertEnter", opts = {} },
  {
    "nguyenvukhang/nvim-toggler",
    dependencies = {
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          local iterator = require "uts.iterator"
          local mappings = iterator(opts.mappings, false)

          mappings "n" {
            ["<Bslash>i"] = { function() require("nvim-toggler").toggle() end, desc = "Toggle CursorWord" },
          }
        end,
      },
    },
    opts = { remove_default_keybinds = true },
  },
}
