return {
  {
    "christoomey/vim-tmux-navigator",
    cond = os.getenv('TMUX'),
    event = "VeryLazy",
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>",  mode = { "n", "o", "v" } },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>",  mode = { "n", "o", "v" } },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>",    mode = { "n", "o", "v" } },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>", mode = { "n", "o", "v" } },
    },
  },
}
