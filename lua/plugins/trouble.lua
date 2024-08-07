return {
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = { focus = true },
    dependencies = {
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          local user_opts = {}
          local prefix = "<Leader>t"

          user_opts.mappings = {
            n = {
              -- [prefix] = { desc = require("astroui").get_icon("Trouble", 1, true) .. "Trouble" },
              [prefix .. "d"] = {
                "<Cmd> Trouble diagnostics toggle filter.buf=0 <Cr>",
                desc = "Buffer Diagnostics (Trouble)",
              },
              [prefix .. "D"] = { "<Cmd> Trouble diagnostics toggle <Cr>", desc = "Workspace Diagnostics (Trouble)" },
              -- [prefix .. "l"] = { "<Cmd>Trouble loclist toggle<CR>", desc = "Location List (Trouble)" },
              -- [prefix .. "q"] = { "<Cmd>Trouble quickfix toggle<CR>", desc = "Quickfix List (Trouble)" },
              -- [prefix .. "t"] = { "<Cmd> Trouble todo <Cr>", desc = "Todo (Trouble)" },
              [prefix .. "T"] = {
                "<cmd>Trouble todo filter={tag={TODO,FIX,FIXME}}<cr>",
                desc = "Todo/Fix/Fixme (Trouble)",
              },
            },
          }

          return vim.tbl_deep_extend("force", opts, user_opts)
        end,
      },
    },
  },
  { "lewis6991/gitsigns.nvim", opts = { trouble = true } },
}
