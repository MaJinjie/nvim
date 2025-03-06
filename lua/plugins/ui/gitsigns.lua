return {
  "lewis6991/gitsigns.nvim",
  event = "LazyFile",
  opts = {
    signs = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "" },
      topdelete = { text = "" },
      changedelete = { text = "▎" },
      untracked = { text = "▎" },
    },
    signs_staged = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "" },
      topdelete = { text = "" },
      changedelete = { text = "▎" },
    },
    -- stylua: ignore
    on_attach = function(buffer)
      local gitsigns = require("gitsigns")

      local function map(mode, l, r, opts) 
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts) 
      end

      -- Navigation
      map("n", "]h", function() if vim.wo.diff then vim.cmd.normal({ "]c", bang = true }) else gitsigns.nav_hunk("next") end end, { desc = "Jump to next git hunk (or diff change)" })
      map("n", "[h", function() if vim.wo.diff then vim.cmd.normal({ "]c", bang = true }) else gitsigns.nav_hunk("prev") end end, { desc = "Jump to prev git hunk (or diff change)" })

      -- Actions
      map('n', '<leader>hs', gitsigns.stage_hunk, { desc = "Stage the current hunk" })
      map('n', '<leader>hr', gitsigns.reset_hunk, { desc = "Reset the current hunk" })
      map('x', '<leader>hs', function() gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, { desc = "Stage the selected lines as a hunk" })
      map('x', '<leader>hr', function() gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, { desc = "Reset the selected lines as a hunk" })
      map('n', '<leader>hS', gitsigns.stage_buffer, { desc = "Stage the entire buffer" })
      map('n', '<leader>hR', gitsigns.reset_buffer, { desc = "Reset the entire buffer" })
      map('n', '<leader>hU', gitsigns.undo_stage_hunk, { desc = "Undo stage the current hunk"})

      -- Preview
      map('n', '<leader>hp', gitsigns.preview_hunk_inline, { desc = "Inline Preview the current hunk" })
      map('n', '<leader>hP', gitsigns.preview_hunk, { desc = "Popup Preview the current hunk" })

      -- Toggles
      map('n', '<leader>hub', gitsigns.toggle_current_line_blame, { desc = "Toggle blame for the current line" })
      map('n', '<leader>hud', gitsigns.toggle_deleted, { desc = "Toggle showing deleted lines" })
      map('n', '<leader>huw', gitsigns.toggle_word_diff, { desc = "Toggle word-level diff highlighting" })

      -- Text object
      map({'o', 'x'}, 'ih', gitsigns.select_hunk, { desc = "Select the current hunk as a text object" })
    end,
  },
}
