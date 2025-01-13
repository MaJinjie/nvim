return {
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    keys = {
      { "<leader>gg", "<cmd>Neogit<cr>", desc = "neogit" },
      { "<leader>gG", "<cmd>lua require'neogit'.open{cwd=require'util.root'{follow=true}}<cr>", desc = "Neogit" },
    },
    opts = {},
  },
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview %" },
      { "<leader>gD", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview" },
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        default = { winbar_info = true },
        file_history = { winbar_info = true },
      },
    },
  },
}
