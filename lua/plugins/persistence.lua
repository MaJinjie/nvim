-- Session management. This saves your session in the background,
-- keeping track of open buffers, window arrangement, and more.
-- You can restore sessions when returning through the dashboard.
return {
  "folke/persistence.nvim",
  event = "BufReadPre",
  opts = {
    pre_save = function()
      vim.api.nvim_exec_autocmds("User", { pattern = "SessionSavePre" })
    end,
  },
  -- stylua: ignore
  keys = {
    { "<leader>qr", function() require("persistence").load() end, desc = "Restore Session" },
    { "<leader>qs", function() require("persistence").select() end,desc = "Select Session" },
    { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
    { "<leader>qS", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
  },
}
