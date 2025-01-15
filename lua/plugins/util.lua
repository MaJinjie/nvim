return {
  --- usage:
  ---   url: https://github.com/Shatur/neovim-session-manager#commands
  {
    "Shatur/neovim-session-manager",
    event = "VimEnter",
    cmd = "SessionManager",
    keys = {
      { "<leader>SL", "<cmd>SessionManager load_session<cr>", desc = "Session load" },
      { "<leader>Sll", "<cmd>SessionManager load_last_session<cr>", desc = "Session load last" },
      { "<leader>Slg", "<cmd>SessionManager load_git_session<cr>", desc = "Session load git" },
      { "<leader>Slc", "<cmd>SessionManager load_current_dir_session<cr>", desc = "Session load cwd" },
      { "<leader>Ss", "<cmd>SessionManager save_current_session<cr>", desc = "Session save" },
      { "<leader>Sd", "<cmd>SessionManager delete_session<cr>", desc = "Session delete" },
      { "<leader>SD", "<cmd>SessionManager delete_current_dir_session<cr>", desc = "Session delete current dir" },
    },
    config = function()
      local mode = require("session_manager.config").AutoloadMode
      require("session_manager").setup({
        autoload_mode = { mode.GitSession, mode.CurrentDir }, -- Define what to do when Neovim is started without arguments. See "Autoload mode" section below.
        autosave_only_in_session = true, -- Always autosaves session. If true, only autosaves after a session is active.
      })
    end,
  },
  {
    "keaising/im-select.nvim",
    event = "InsertEnter",
    opts = { set_default_events = { "InsertLeave" } },
  },
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    opts = { default_mappings = false, mappings = { i = { j = { k = "<Esc>" }, k = { j = "<Esc>" } } } },
  },
  --- usage:
  ---   commands:
  ---     LazyDev lsp   显示当前所有已连接的lsp设置
  ---     LazyDev debug 显示当前缓冲区lazydev设置
  {
    "folke/lazydev.nvim",
    ft = "lua",
    cmd = "LazyDev",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  -- Manage libuv types with lazy. Plugin will never be loaded
  { "Bilal2453/luvit-meta", lazy = true },
  -- utils functions
  { "nvim-lua/plenary.nvim", lazy = true },
  { "nvim-neotest/nvim-nio", lazy = true },
}
