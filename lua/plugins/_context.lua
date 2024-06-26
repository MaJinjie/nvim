---@type LazySpec
return {
  { "kylechui/nvim-surround", version = "*", event = "User AstroFile", opts = {} },
  {
    "Wansmer/treesj",
    cmd = "TSJToggle",
    opts = { use_default_keymaps = false },
    dependencies = {
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          local iterator = require "uts.iterator"
          local mappings = iterator(opts.mappings, false)

          mappings "n" {
            ["\\j"] = { "<Cmd> TSJToggle <Cr>", desc = "Toggle Treesitter Join" },
          }
        end,
      },
    },
  },
  { "terryma/vim-expand-region", event = { "User AstroFile" } },
}
