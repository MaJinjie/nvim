return {
  {
    "jvgrootveld/telescope-zoxide",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-telescope/telescope-file-browser.nvim" },
    commander = { { cmd = "<cmd> Telescope zoxide list<cr>", desc = "tel zoxide" } },
    config = require("custom.plugins.configs.telescope_extensions").zoxide,
  },
  {
    "lmburns/telescope-rualdi.nvim",
    dir = "~/.config/nvim/dev/telescope-rualdi.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    commander = { { cmd = "<cmd> Telescope rualdi list<cr>", desc = "tel rualdi" } },
    config = require("custom.plugins.configs.telescope_extensions").rualdi,
  },
  ------------------------------[[dirs jump ]]------------------------------$
  {
    "prochri/telescope-all-recent.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "kkharji/sqlite.lua",
      -- optional, if using telescope for vim.ui.select
      "stevearc/dressing.nvim",
    },
    config = require("custom.plugins.configs.telescope_extensions").recent,
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
    keys = {
      {
        "<leader>ep",
        function()
          local wd = vim.loop.cwd()
          local cd = vim.fn.expand "%:p:h"
          local cwd
          if wd == cd then
            cwd = vim.fn.fnamemodify(cd, ":h")
          else
            cwd = wd
          end
          vim.cmd("Telescope file_browser path=" .. cwd)
        end,
        desc = "open filw_brower w",
        silent = true,
      },
      {
        "<leader>ee",
        "<cmd> Telescope file_browser path=%:p:h <CR>",
        desc = "open file_brower .",
        silent = true,
      },
      {
        "<leader>eh",
        "<cmd> Telescope file_browser path=~ <CR>",
        desc = "find home files",
        silent = true,
      },
      {
        "<leader>e/",
        "<cmd> Telescope file_browser path=/ <CR>",
        desc = "find root files",
        silent = true,
      },
    },
    init = function()
      if vim.fn.argc(-1) == 1 then
        local stat = vim.loop.fs_stat(vim.fn.argv(0))
        if stat and stat.type == "directory" then
          require("telescope").load_extension "file_browser"
        end
      end
    end,
    config = require("custom.plugins.configs.telescope_extensions").file_browser,
  },
}
