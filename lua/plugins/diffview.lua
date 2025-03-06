local M = {}

function M.view_windo_unique(cmd)
  local function is_unique(layout, symbol)
    if layout == "diff2_horizontal" or layout == "diff2_vertical" then
      return symbol == "b"
    end
    return true
  end

  local fun
  -- stylua: ignore
  if type(cmd) == "string" then
    fun = function(_, _) vim.cmd(cmd) end
  else
    fun = cmd
  end

  return require("diffview.actions").view_windo(function(...)
    if is_unique(...) then
      fun(...)
    end
  end)
end

return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewRefresh" },
  -- stylua: ignore
  keys = {
    { "<leader>g%", "<cmd>DiffviewFileHistory %<cr>", desc = "DiffviewFileHistory the current file" },
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Open Diffview" },
    { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
  },
  opts = function()
    local actions = require "diffview.actions"
    require("diffview.config")

    return {
      enhanced_diff_hl = true,
      file_panel = {
        win_config = {
          win_opts = {
            winfixbuf = true,
            winfixwidth = true,
          },
        },
      },
      file_history_panel = {
        win_config = {
          height = 14,
          win_opts = {
            winfixbuf = true,
            winfixheight = true,
          },
        },
      },
      -- stylua: ignore
      keymaps = {
        disable_defaults = false, -- Disable the default keymaps
        view = {
          -- The `view` bindings are active in the diff buffers, only when the current
          -- tabpage is a Diffview.
          { "n", "]f", actions.select_next_entry, { desc = "Open the diff for the next file" } },
          { "n", "[f", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },
          { "n", "[F", actions.select_first_entry, { desc = "Open the diff for the first file" } },
          { "n", "]F", actions.select_last_entry, { desc = "Open the diff for the last file" } },

          { "n", "<c-e>", actions.goto_file_edit, { desc = "Open the file in the previous tabpage" } },
          { "n", "<c-s>", actions.goto_file_split, { desc = "Open the file in a new split" } },
          { "n", "<c-t>", actions.goto_file_tab, { desc = "Open the file in a new tabpage" } },

          { "n", "[c", "<cmd>norm! [c<cr>", { desc = "Jump to the prev diff" } },
          { "n", "]c", "<cmd>norm! ]c<cr>", { desc = "Jump to the next diff" } },
          { "n", "[C", actions.select_prev_commit, { desc = "Open the diff for the prev commit" } },
          { "n", "]C", actions.select_next_commit, { desc = "Open the diff for the next commit" } },

          { "n", "<leader>e", actions.focus_files, { desc = "Bring focus to the file panel" } },
          { "n", "<leader>E", actions.toggle_files, { desc = "Toggle the file panel." } },

          { "n", "[x", actions.prev_conflict, { desc = "In the merge-tool: jump to the previous conflict" } },
          { "n", "]x", actions.next_conflict, { desc = "In the merge-tool: jump to the next conflict" } },
          { "n", "<leader>co", actions.conflict_choose("ours"), { desc = "Choose the OURS version of a conflict" } },
          { "n", "<leader>ct", actions.conflict_choose("theirs"), { desc = "Choose the THEIRS version of a conflict" } },
          { "n", "<leader>cb", actions.conflict_choose("base"), { desc = "Choose the BASE version of a conflict" } },
          { "n", "<leader>ca", actions.conflict_choose("all"), { desc = "Choose all the versions of a conflict" } },
          { "n", "<leader>cx", actions.conflict_choose("none"), { desc = "Delete the conflict region" } },
          { "n", "<leader>cO", actions.conflict_choose_all("ours"), { desc = "Choose the OURS version of a conflict for the whole file" } },
          { "n", "<leader>cT", actions.conflict_choose_all("theirs"), { desc = "Choose the THEIRS version of a conflict for the whole file" } },
          { "n", "<leader>cB", actions.conflict_choose_all("base"), { desc = "Choose the BASE version of a conflict for the whole file" } },
          { "n", "<leader>cA", actions.conflict_choose_all("all"), { desc = "Choose all the versions of a conflict for the whole file" } },
          { "n", "<leader>cX", actions.conflict_choose_all("none"), { desc = "Delete the conflict region for the whole file" } },
        },
        file_panel = {
          -- { "n", "g-", actions.options, { desc = "Open the option panel" } },
          { "n", "g?", actions.help("file_history_panel"), { desc = "Open the help panel" } },

          { "n", "C", actions.cycle_layout, { desc = "Cycle available layouts" } },
          -- { "n", "D", actions.open_in_diffview, { desc = "Open the entry under the cursor in a diffview" } },
          { "n", "L", actions.open_commit_log, { desc = "Show commit details" } },
          -- { "n", "Y", actions.copy_hash, { desc = "Copy the commit hash of the entry under the cursor" } },
          { "n", "r", actions.restore_entry, { desc = "Restore file to the state from the selected entry" } },
          { "n", "R", actions.refresh_files, { desc = "Refresh files" } },

          { "n", "h", actions.close_fold, { desc = "Collapse fold" } },
          { "n", "j", actions.next_entry, { desc = "Bring the cursor to the next file entry" } },
          { "n", "k", actions.prev_entry, { desc = "Bring the cursor to the previous file entry" } },
          { "n", "l", actions.select_entry, { desc = "Open the diff for the selected entry" } },
          { "n", "gg", actions.select_first_entry, { desc = "Open the diff for the first file" } },
          { "n", "G", actions.select_last_entry, { desc = "Open the diff for the last file" } },
          { "n", "<tab>", actions.select_next_entry, { desc = "Open the diff for the next file" } },
          { "n", "<s-tab>", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },

          { "n", "o", actions.select_entry, { desc = "Open the diff view" } },
          { "n", "O", actions.focus_entry, { desc = "Focus the diff view" } },
          { "n", "<cr>", function() actions.focus_entry() actions.toggle_files() end, { desc = "Focus diff view and Close the file panel" } },

          { "n", "[c", M.view_windo_unique("norm! [c"), { desc = "Goto the prev diff" } },
          { "n", "]c", M.view_windo_unique("norm! ]c"), { desc = "Goto the prev diff" } },

          { "n", "d", "<C-d>", { nowait = true, desc = "Half-page Down" } },
          { "n", "u", "<C-u>", { nowait = true, desc = "Half-page up" } },
          { "n", "b", actions.scroll_view(-0.3), { desc = "Scroll the view up" } },
          { "n", "f", actions.scroll_view(0.3), { desc = "Scroll the view down" } },

          { "n", "<c-e>", actions.goto_file_edit, { desc = "Open the file in the previous tabpage" } },
          { "n", "<c-s>", actions.goto_file_split, { desc = "Open the file in a new split" } },
          { "n", "<c-t>", actions.goto_file_tab, { desc = "Open the file in a new tabpage" } },

          { "n", "<leader>e", function() User.util.qcall({"wincmd p", actions.focus_entry}) end, { desc = "Bring focus to the file panel" } },
          { "n", "<leader>E", actions.toggle_files, { desc = "Toggle the file panel" } },

          { "n", "q", actions.close, { desc = "Close the panel" } },

          { "n", "-", actions.toggle_stage_entry, { desc = "Stage / unstage the selected entry" } },
          { "n", "S", actions.stage_all, { desc = "Stage all entries" } },
          { "n", "U", actions.unstage_all, { desc = "Unstage all entries" } },
          { "n", "I", actions.listing_style, { desc = "Toggle between 'list' and 'tree' views" } },
          { "n", "F", actions.toggle_flatten_dirs, { desc = "Flatten empty subdirectories in tree listing style" } },

          { "n", "[x", actions.prev_conflict, { desc = "Go to the previous conflict" } },
          { "n", "]x", actions.next_conflict, { desc = "Go to the next conflict" } },
          { "n", "cO", actions.conflict_choose_all("ours"), { desc = "Choose the OURS version of a conflict for the whole file" } },
          { "n", "cT", actions.conflict_choose_all("theirs"), { desc = "Choose the THEIRS version of a conflict for the whole file" } },
          { "n", "cB", actions.conflict_choose_all("base"), { desc = "Choose the BASE version of a conflict for the whole file" } },
          { "n", "cA", actions.conflict_choose_all("all"), { desc = "Choose all the versions of a conflict for the whole file" } },
          { "n", "cX", actions.conflict_choose_all("none"), { desc = "Delete the conflict region for the whole file" } },
        },
        -- stylua: ignore
        file_history_panel = {
          { "n", "g-", actions.options, { desc = "Open the option panel" } },
          { "n", "g?", actions.help("file_history_panel"), { desc = "Open the help panel" } },

          { "n", "C", actions.cycle_layout, { desc = "Cycle available layouts" } },
          { "n", "D", actions.open_in_diffview, { desc = "Open the entry under the cursor in a diffview" } },
          { "n", "L", actions.open_commit_log, { desc = "Show commit details" } },
          { "n", "Y", actions.copy_hash, { desc = "Copy the commit hash of the entry under the cursor" } },
          { "n", "r", actions.restore_entry, { desc = "Restore file to the state from the selected entry" } },
          { "n", "R", actions.refresh_files, { desc = "Refresh files" } },

          { "n", "h", actions.close_fold, { desc = "Collapse fold" } },
          { "n", "j", actions.next_entry, { desc = "Bring the cursor to the next file entry" } },
          { "n", "k", actions.prev_entry, { desc = "Bring the cursor to the previous file entry" } },
          { "n", "l", actions.select_entry, { desc = "Open the diff for the selected entry" } },
          { "n", "gg", actions.select_first_entry, { desc = "Open the diff for the first file" } },
          { "n", "G", actions.select_last_entry, { desc = "Open the diff for the last file" } },
          { "n", "K", actions.select_prev_commit, { desc = "Open the diff for the prev commit" } },
          { "n", "J", actions.select_next_commit, { desc = "Open the diff for the next commit" } },
          { "n", "<tab>", actions.select_next_entry, { desc = "Open the diff for the next file" } },
          { "n", "<s-tab>", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },

          { "n", "o", actions.select_entry, { desc = "Open the diff view" } },
          { "n", "O", actions.focus_entry, { desc = "Focus the diff view" } },
          { "n", "<cr>", function() actions.focus_entry() actions.toggle_files() end, { desc = "Focus diff view and Close the file panel" } },

          { "n", "[c", M.view_windo_unique("norm! [c"), { desc = "Goto the prev diff" } },
          { "n", "]c", M.view_windo_unique("norm! ]c"), { desc = "Goto the prev diff" } },

          { "n", "d", "<C-d>", { nowait = true, desc = "Half-page Down" } },
          { "n", "u", "<C-u>", { nowait = true, desc = "Half-page up" } },
          { "n", "b", actions.scroll_view(-0.3), { desc = "Scroll the view up" } },
          { "n", "f", actions.scroll_view(0.3), { desc = "Scroll the view down" } },

          { "n", "<c-e>", actions.goto_file_edit, { desc = "Open the file in the previous tabpage" } },
          { "n", "<c-s>", actions.goto_file_split, { desc = "Open the file in a new split" } },
          { "n", "<c-t>", actions.goto_file_tab, { desc = "Open the file in a new tabpage" } },

          { "n", "<leader>e", function() User.util.qcall({"wincmd p", actions.focus_entry}) end, { desc = "Bring focus to the file panel" } },
          { "n", "<leader>E", actions.toggle_files, { desc = "Toggle the file panel" } },

          { "n", "q", actions.close, { desc = "Close the panel" } },
        },
        option_panel = {
          { "n", "<tab>", actions.select_entry, { desc = "Change the current option" } },
          { "n", "q", actions.close, { desc = "Close the panel" } },
          { "n", "g?", actions.help("option_panel"), { desc = "Open the help panel" } },
        },
        help_panel = {
          { "n", "q", actions.close, { desc = "Close help menu" } },
          { "n", "<esc>", actions.close, { desc = "Close help menu" } },
        },
        -- diff1 = {
        -- Mappings in single window diff layouts
        -- { "n", "g?", actions.help({ "view", "diff1" }), { desc = "Open the help panel" } },
        -- },
        -- diff2 = {
        -- Mappings in 2-way diff layouts
        -- { "n", "g?", actions.help({ "view", "diff2" }), { desc = "Open the help panel" } },
        -- },
        -- diff3 = {
        -- Mappings in 3-way diff layouts
        -- { { "n", "x" }, "2do", actions.diffget("ours"), { desc = "Obtain the diff hunk from the OURS version of the file" } },
        -- { { "n", "x" }, "3do", actions.diffget("theirs"), { desc = "Obtain the diff hunk from the THEIRS version of the file" } },
        -- { "n", "g?", actions.help({ "view", "diff3" }), { desc = "Open the help panel" } },
        -- },
        -- diff4 = {
        -- Mappings in 4-way diff layouts
        -- { { "n", "x" }, "1do", actions.diffget("base"), { desc = "Obtain the diff hunk from the BASE version of the file" } },
        -- { { "n", "x" }, "2do", actions.diffget("ours"), { desc = "Obtain the diff hunk from the OURS version of the file" } },
        -- { { "n", "x" }, "3do", actions.diffget("theirs"), { desc = "Obtain the diff hunk from the THEIRS version of the file" } },
        -- { "n", "g?", actions.help({ "view", "diff4" }), { desc = "Open the help panel" } },
        -- },
      },
    }
  end,
}
