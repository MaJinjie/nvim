return {
  {
    "nvim-telescope/telescope-frecency.nvim",
    enabled = false,
    dependencies = { "nvim-telescope/telescope.nvim" },
    keys = {
      { "<leader>fr", "<Cmd>Telescope frecency<CR>",               desc = "recent files" },
      { "<leader>fR", "<Cmd>Telescope frecency workspace=CWD<CR>", desc = "recent files(cwd)" },
    },
    config = function()
      require("telescope").setup({
        extensions = {
          frecency = {
            show_scores = true,
            show_unindexed = true,
            hide_current_buffer = true,
            show_filter_column = { "LSP", "CWD" },
            ignore_patterns = { "*.git/*", "*/tmp/*" },
            workspaces = {
              ["conf"] = "/home/mjj/.config",
              ["data"] = "/home/mjj/.local/share",
              ["lazy"] = "/home/mjj/.local/share/nvim/lazy",
              ["v"] = "/home/mjj/.config/nvim",
              ["lv"] = "/home/mjj/.local/share/nvim/lazy/LazyVim/lua/lazyvim",
            },
          },
        },
      })
      require("telescope").load_extension("frecency")
    end,
  },
}
