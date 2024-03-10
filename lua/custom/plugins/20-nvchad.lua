return {
  {
    "williamboman/mason.nvim",
    opts = {
      -- lua
      "lua-language-server",
      "stylua",
      "luacheck",
      -- cpp c
      "clangd",
      "clang-format",
      -- cmake
      "cmake-language-server",
      "cmakelang",
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "c",
        "cpp",
        "cmake",
        "make",
        "lua",
        "luadoc",
        "vim",
        "vimdoc",
        -- "sql",
        "bash",
        -- "html", "css", "javascript", "typescript",
        -- "go",
        -- "python",
        "tmux",
        "toml",
        "yaml",
        "ssh_config",
        "regex",
        "query",
      },
    },
  },
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "hrsh7th/cmp-cmdline",
      "dmitmel/cmp-cmdline-history",
    },
    opts = {},
    config = function()
      require "custom.plugins.configs.cmp"
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "folke/neoconf.nvim", cmd = "Neoconf", config = false, dependencies = { "nvim-lspconfig" } },
      "folke/neodev.nvim",
    },
    event = "User FilePost",
    config = function()
      require "plugins.configs.lspconfig"
    end,
  },

  {
    "folke/neodev.nvim",
    opts = {
      library = {
        enabled = true, -- when not enabled, neodev will not change any settings to the LSP server
        -- these settings will be used for your Neovim config directory
        runtime = true, -- runtime path
        types = true, -- full signature, docs and completion of vim.api, vim.treesitter, vim.lsp and others
        plugins = { "nvim-ufo" }, -- installed opt or start plugins in packpath
        -- you can also specify the list of plugins to make available as a workspace library
        -- plugins = { "nvim-treesitter", "plenary.nvim", "telescope.nvim" },
      },
    },
  },
}
