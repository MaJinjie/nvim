---@type LazySpec
return {
  {
    "folke/flash.nvim",
    keys = { "f", "F", "t", "T" },
    opts = {},
    dependencies = {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local iterator = require "uts.iterator"
        local mappings = iterator(opts.mappings, false)

        mappings "n" {
          ["s"] = { function() require("flash").jump() end, desc = "Flash" },
          ["S"] = { function() require("flash").treesitter() end, desc = "Flash Treesitter" },
        }
        mappings "x" {
          ["s"] = { function() require("flash").jump() end, desc = "Flash" },
          ["R"] = { function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
          ["S"] = { function() require("flash").treesitter() end, desc = "Flash Treesitter" },
        }
        mappings "o" {
          ["r"] = { function() require("flash").remote() end, desc = "Remote Flash" },
          ["R"] = { function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
          ["s"] = { function() require("flash").jump() end, desc = "Flash" },
          ["S"] = { function() require("flash").treesitter() end, desc = "Flash Treesitter" },
        }
      end,
    },
  },
  {
    "chrisgrieser/nvim-spider",
    opts = { consistentOperatorPending = true },
    dependencies = {
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          local iterator = require "uts.iterator"
          local mappings = iterator(opts.mappings, false)

          mappings { "n", "x", "o" } {
            ["w"] = { "<Cmd>lua require('spider').motion('w')<CR>", desc = "Next word" },
            ["e"] = { "<Cmd>lua require('spider').motion('e')<CR>", desc = "Next end of word" },
            ["b"] = { "<Cmd>lua require('spider').motion('b')<CR>", desc = "Previous word" },
            ["ge"] = { "<Cmd>lua require('spider').motion('ge')<CR>", desc = "Previous end of word" },
          }
        end,
      },
    },
  },
  {
    "cbochs/grapple.nvim",
    cmd = "Grapple",
    opts = { scope = "git" },
    dependencies = {
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          local iterator = require "uts.iterator"
          local mappings = iterator(opts.mappings, false)

          mappings "n" {
            ["<Bslash>a"] = { "<Cmd>Grapple tag<CR>", desc = "Add file" },
            ["<Bslash>A"] = { "<Cmd>Grapple untag<CR>", desc = "Remove file" },
            ["<Bslash>w"] = { "<Cmd>Grapple toggle_tags<CR>", desc = "Toggle a file" },
            ["<Bslash>W"] = { "<Cmd>Telescope grapple tags<CR>", desc = "Toggle a file using telescope" },
            ["<C-n>"] = { "<Cmd>Grapple cycle forward<CR>", desc = "Select next tag" },
            ["<C-p>"] = { "<Cmd>Grapple cycle backward<CR>", desc = "Select previous tag" },
          }
        end,
      },
    },
  },
}
