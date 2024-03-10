return {
  {
        "folke/flash.nvim",
    -- stylua: ignore
    keys = {
      { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
      { "S",     mode = { "n", "o" },      function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
      { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
      { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
    },
  },
  {
    "smoka7/multicursors.nvim",
    dependencies = {
      "smoka7/hydra.nvim",
    },
    cmd = {  "MCpattern", "MCvisualPattern"},
    commander = {
      {cmd = "<cmd> MCPattern <cr>", desc = "mc pattern"},
      -- {cmd = "<cmd> MCvisualPattern <cr>", desc = "mc vpattern"},
    },
    keys = {
      {
        mode = { "x", "n" },
        "<Leader>cw",
        "<cmd>MCstart<cr>",
        desc = "mc start",
      },
      {
        "<Leader>cu",
        "<cmd>MCunderCursor<cr>",
        desc = "mc under",
      },
      {
        mode = { "x", "n" },
        "<Leader>cU",
        "<cmd>MCclear<cr>",
        desc = "mc clear",
      },
    },
    opts = function()
      local N = require("multicursors.normal_mode")
      local I = require("multicursors.insert_mode")
      local E = require("multicursors.extend_mode")

      return {
        hint_config = {
          border = "rounded",
          position = "bottom-right",
        },
        generate_hints = {
          normal = true,
          insert = true,
          extend = true,
          config = {
            column_count = 1,
          },
        },
        normal_keys = {
          ["j"] = { method = false },
          ["k"] = { method = false },
          ["<C-n>"] = { method = false },
          [","] = { method = false },
          ["u"] = { method = false },
          ["U"] = { method = false },
          ["J"] = { method = N.create_down, opts = { desc = "Create down" } },
          ["K"] = { method = N.create_up, opts = { desc = "Create up" } },
          ["<C-o>"] = {
            method = N.clear_others,
            opts = { desc = "Clear others" },
          },
          ["m"] = {
            method = N.create_char,
            opts = { desc = "Creates under cursor" },
          },
          ["."] = { method = N.dot_repeat, opts = { desc = "Dot repeat" } },
          ["n"] = { method = N.find_next, opts = { desc = "Find next" } },
          ["N"] = { method = N.find_prev, opts = { desc = "Find prev" } },
          ["q"] = { method = N.skip_find_next, opts = { desc = "Skip find next" } },
          ["Q"] = { method = N.skip_find_prev, opts = { desc = "Skip find prev" } },
          [">"] = { method = N.upper_case, opts = { desc = "Upper case" } },
          ["<"] = { method = N.lower_case, opts = { desc = "lower case" } },
          ["}"] = { method = N.skip_goto_next, opts = { desc = "Skip Goto next" } },
          ["{"] = { method = N.skip_goto_prev, opts = { desc = "Skip Goto prev" } },
          ["]"] = { method = N.goto_next, opts = { desc = "Goto next" } },
          ["["] = { method = N.goto_prev, opts = { desc = "Goto prev" } },
          ["p"] = { method = N.paste_after, opts = { desc = "Paste after" } },
          ["r"] = { method = N.replace, opts = { desc = "Replace selections text" } },
          ["P"] = { method = N.paste_before, opts = { desc = "Paste before" } },
          ["@"] = { method = N.run_macro, opts = { desc = "Run macro" } },
          [":"] = { method = N.normal_command, opts = { desc = "Normal command" } },
          ["y"] = { method = N.yank, opts = { desc = "Yank", nowait = false } },
          ["Y"] = { method = N.yank_end, opts = { desc = "Yank end" } },
          ["yy"] = { method = N.yank_line, opts = { desc = "Yank line" } },
          ["d"] = { method = N.delete, opts = { desc = "Delete", nowait = false } },
          ["dd"] = { method = N.delete_line, opts = { desc = "Delete line" } },
          ["D"] = { method = N.delete_end, opts = { desc = "Delete end" } },
        },
        insert_keys = {},
        extend_keys = {},
      }
    end,
  },
}
