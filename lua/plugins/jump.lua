---@type LazySpec
return {
  {
    "chrisgrieser/nvim-spider",
    opts = { consistentOperatorPending = true },
    specs = {
      "AstroNvim/astrocore",
      opts = function()
        local map = require("utils").keymap.set

        map[{ "n", "x", "o" }] {
          ["w"] = { "<Cmd>lua require('spider').motion('w')<CR>", desc = "Next word" },
          ["e"] = { "<Cmd>lua require('spider').motion('e')<CR>", desc = "Next end of word" },
          ["b"] = { "<Cmd>lua require('spider').motion('b')<CR>", desc = "Previous word" },
          ["ge"] = { "<Cmd>lua require('spider').motion('ge')<CR>", desc = "Previous end of word" },
        }
      end,
    },
  },
  { "kylechui/nvim-surround", version = "*", event = "User AstroFile", opts = { aliases = {} } },
  {
    "Wansmer/treesj",
    cmd = "TSJToggle",
    opts = { use_default_keymaps = false },
    specs = {
      "AstroNvim/astrocore",
      opts = function()
        local nmap = require("utils").keymap.set.n

        nmap { ["<Leader>j"] = { "<Cmd> TSJToggle <Cr>", desc = "[treesj] Toggle Treesitter Join" } }
      end,
    },
  },
  {
    "max397574/better-escape.nvim",
    event = { "InsertEnter", "CmdlineEnter", "TermEnter" },
    opts = {
      timeout = 300,
      mappings = { i = { j = { k = "<Esc>" } }, c = { j = { k = "<Esc>" } }, t = { j = { k = "<C-\\><C-N>" } } },
    },
  },
  {
    "folke/flash.nvim",
    event = "User AstroFile",
    opts = {
      label = { after = false, before = true },
      modes = {
        char = {
          config = function(opts)
            -- autohide flash when in operator-pending mode
            opts.autohide = opts.autohide or (vim.fn.mode(true):find "no" and vim.v.operator ~= "d")

            -- disable jump labels when not enabled, when using a count,
            -- or when recording/executing registers
            -- opts.jump_labels = opts.jump_labels
            --   and vim.v.count == 0
            --   and vim.fn.reg_executing() == ""
            --   and vim.fn.reg_recording() == ""
            -- print(opts.autohide, opts.jump_labels)

            -- Show jump labels only in operator-pending mode
            opts.jump_labels = vim.v.count == 0 and vim.fn.mode(true):match "^n$"
          end,
          label = { exclude = "hjkliarydc" },
        },
      },
    },
    specs = {
      "AstroNvim/astrocore",
      opts = function()
        local map = require("utils").keymap.set

        map {
          n = {
            ["s"] = { function() require("flash").jump() end, desc = "Flash" },
            ["S"] = { function() require("flash").treesitter() end, desc = "Flash Treesitter" },
          },
          x = {
            ["s"] = { function() require("flash").jump() end, desc = "Flash" },
            ["S"] = { function() require("flash").treesitter() end, desc = "Flash Treesitter" },
            ["R"] = { function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
          },
          o = {
            ["s"] = { function() require("flash").jump() end, desc = "Flash" },
            ["S"] = { function() require("flash").treesitter() end, desc = "Flash Treesitter" },
            ["r"] = { function() require("flash").remote() end, desc = "Remote Flash" },
            ["R"] = { function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
          },
          c = {
            ["<C-z>"] = { function() require("flash").toggle() end, desc = "Toggle Flash Search" },
          },
        }
      end,
    },
  },
  { "keaising/im-select.nvim", event = "InsertEnter", opts = {} },
  {
    "willothy/flatten.nvim",
    lazy = false,
    opts = { window = { open = "alternate" } },
    priority = 1001,
  },
  { "windwp/nvim-autopairs", opts = { fast_wrap = { map = "<M-a>", end_key = ";" } } },
}
