--flash [[s(nxo) S(no) r(o) R(xo)]]
return {
  {
    "smoka7/multicursors.nvim",
    event = "VeryLazy",
    dependencies = {
      "smoka7/hydra.nvim",
    },
    cmd = { "MCstart", "MCvisual", "MCclear", "MCpattern", "MCvisualPattern", "MCunderCursor" },
    keys = {
      {
        mode = { "x", "n" },
        "<Leader>mw",
        "<cmd>MCstart<cr>",
        desc = "Create a selection for selected text or word under the cursor",
      },
      {
        mode = { "x", "n" },
        "<Leader>mu",
        "<cmd>MCunderCursor<cr>",
        desc = "under Cursor",
      },
      {
        mode = { "x", "n" },
        "<Leader>mc",
        "<cmd>MCclear<cr>",
        desc = "clear cursor",
      },
      {
        mode = { "n" },
        "<Leader>mp",
        "<cmd>MCpattern<cr>",
        desc = "pattern",
      },
      {
        mode = { "n" },
        "<Leader>mv",
        "<cmd>MCvisualPattern<cr>",
        desc = "visual pattern",
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
    config = function(_, opts)
      require("config.highlight").multiCursor()
      require("multicursors").setup(opts)
    end,
  },
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
    },
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>",  mode = { "n", "o", "v" } },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>",  mode = { "n", "o", "v" } },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>",    mode = { "n", "o", "v" } },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>", mode = { "n", "o", "v" } },
    },
  },
  {
    "karb94/neoscroll.nvim",
    config = function()
      require("neoscroll").setup({
        -- All these keys will be mapped to their corresponding default scrolling animation
        mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "<C-y>", "<C-e>", "zt", "zz", "zb" },
        hide_cursor = true,          -- Hide cursor while scrolling
        stop_eof = true,             -- Stop at <EOF> when scrolling downwards
        respect_scrolloff = false,   -- Stop scrolling when the cursor reaches the scrolloff margin of the file
        cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
        easing_function = nil,       -- Default easing function
        pre_hook = nil,              -- Function to run before the scrolling animation starts
        post_hook = nil,             -- Function to run after the scrolling animation ends
        performance_mode = false,    -- Disable "Performance Mode" on all buffers.
      })
    end,
  },
  {
    "max397574/better-escape.nvim",
    event = "InsertCharPre",
    opts = {
      mapping = { "jk", "JK" },
      timeoutlen = 250,
      clear_empty_lines = false,
    },
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    ---@type Flash.Config
    opts = {},
    -- stylua: ignore
    keys = {
      { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
      { "S",     mode = { "n", "o" },      function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
      { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
      { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
    },
  },
}
