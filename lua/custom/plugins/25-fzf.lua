return {
  "ibhagwan/fzf-lua",
  keys = {
    -- grep
    {
      "<leader>s.",
      function()
        require("fzf-lua").grep_project { cwd = vim.fn.expand "%:p:h" }
      end,
      desc = "rg .",
    },
    {
      "<leader>sp",
      function()
        local wd = vim.loop.cwd()
        local cd = vim.fn.expand "%:p:h"
        local cwd
        if wd == cd then
          cwd = vim.fn.fnamemodify(cd, ":h")
        else
          cwd = wd
        end
        require("fzf-lua").grep_project { cwd = cwd }
      end,
      desc = "rg .",
    },
    {
      "<leader>sc",
      function()
        require("fzf-lua").grep_project { cwd = "~/.config/nvim" }
      end,
      desc = "rg cfiles",
    },
    {
      "<leader>sl",
      function()
        require("fzf-lua").grep_last {}
      end,
      desc = "rg last",
    },
    {
      "<leader>sb",
      function()
        require("fzf-lua").grep_curbuf {}
      end,
      desc = "rg curbuf",
    },

    {
      '<leader>s"',
      function()
        require("fzf-lua").registers()
      end,
      desc = "registers",
    },
    -- files
    {
      "<leader>ff",
      function()
        require("fzf-lua").files { cwd = vim.fn.expand "%:p:h" }
      end,
      desc = "fd .",
    },
    {
      "<leader>fp",
      function()
        local wd = vim.loop.cwd()
        local cd = vim.fn.expand "%:p:h"
        local cwd
        if wd == cd then
          cwd = vim.fn.fnamemodify(cd, ":h")
        else
          cwd = wd
        end
        require("fzf-lua").files { cwd = cwd }
      end,
      desc = "fd pwd",
    },
    {
      "<leader>fb",
      function()
        require("fzf-lua").buffers {}
      end,
      desc = "fd bufs",
    },
    {
      "<leader>fc",
      function()
        require("fzf-lua").files { cwd = "~/.config/nvim" }
      end,
      desc = "fd cfiles",
    },
    {
      "<leader>fo",
      function()
        require("fzf-lua").oldfiles {}
      end,
      desc = "fd oldfiles",
    },
    -- git
    {
      "<leader>fg",
      function()
        require("fzf-lua").git_files {}
      end,
      desc = "git files",
    },
    {
      "<leader>fs",
      function()
        require("fzf-lua").git_status {}
      end,
      desc = "git status",
    },
    -- jumps changes help_tags man_pages marks
    {
      "<leader>j",
      function()
        require("fzf-lua").jumps()
      end,
      desc = "jumps",
    },
    {
      "<leader>k",
      function()
        require("fzf-lua").changes()
      end,
      desc = "changes",
    },
    {
      "<leader>fm",
      function()
        require("fzf-lua").man_pages()
      end,
      desc = "man pages",
    },
    {
      "<leader>sh",
      function()
        require("fzf-lua").help_tags()
      end,
      desc = "help tags",
    },
    {
      "<leader>sm",
      function()
        require("fzf-lua").marks()
      end,
      desc = "marks",
    },
    {
      "<leader>rf",
      function()
        require("fzf-lua").resume()
      end,
      desc = "fzf resume",
    },
    { "<leader>tt", "<cmd> FzfLua <cr>", desc = "fzf" },
  },
  commander = {
    -- commands keymaps registers colors spellsuggest autocmds
    {
      cmd = function()
        require("fzf-lua").commands()
      end,
      desc = "commands",
    },
    {
      cmd = function()
        require("fzf-lua").autocmds()
      end,
      desc = "autocmds",
    },
    {
      cmd = function()
        require("fzf-lua").keymaps()
      end,
      desc = "keymaps",
    },
    {
      cmd = function()
        require("fzf-lua").filetypes()
      end,
      desc = "filetypes",
    },
    {
      cmd = function()
        require("fzf-lua").colorschemes()
      end,
      desc = "colorschemes",
    },
    {
      cmd = function()
        require("fzf-lua").spell_suggest()
      end,
      desc = "spell suggest",
    },
    -- live_grep
    {
      cmd = function()
        require("fzf-lua").live_grep_native()
      end,
      desc = "lrg native",
    },
    {
      cmd = function()
        require("fzf-lua").live_grep_glob()
      end,
      desc = "lrg glob",
    },
    {
      cmd = function()
        require("fzf-lua").live_grep_resume()
      end,
      desc = "lrg resume",
    },
    -- grep
    {
      cmd = function()
        require("fzf-lua").grep_cword()
      end,
      desc = "rg lcword",
    },
    {
      cmd = function()
        require("fzf-lua").grep_cWORD()
      end,
      desc = "rg ucWORD",
    },
    {
      cmd = function()
        require("fzf-lua").grep_visual()
      end,
      desc = "rg visual",
    },
    {
      cmd = function()
        require("fzf-lua").grep_project()
      end,
      desc = "rg project",
    },
    -- git
    {
      cmd = function()
        require("fzf-lua").git_branches()
      end,
      desc = "git branches",
    },
    {
      cmd = function()
        require("fzf-lua").git_commits()
      end,
      desc = "git commits",
    },
  },
  -- optional for icon support
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = require "custom.plugins.configs.fzf",
}
