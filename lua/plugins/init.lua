local require = User.util.safe_require

return {
  -- dev
  require "plugins.yazi-meta",
  -- ui
  require "plugins.colorschemes",
  require "plugins.mini-icons",
  require "plugins.noice",
  require "plugins.snacks_ui",
  require "plugins.heirline",
  require "plugins.bufferline",
  require "plugins.aerial",
  require "plugins.nvim-colorizer",

  -- ts
  require "plugins.ts",
  require "plugins.ts-context",
  require "plugins.ts-autotag",
  require "plugins.ts-j",

  -- edit
  require "plugins.blink-cmp",
  require "plugins.snippets",
  require "plugins.ultimate-autopair",
  require "plugins.nvim-surround",
  require "plugins.mini-ai",
  require "plugins.comments",
  require "plugins.grug-far",
  require "plugins.vim-visual-multi",

  -- ops
  require "plugins.which-key",
  require "plugins.yanky",
  require "plugins.dial",
  require "plugins.bqf",
  require "plugins.mini-map",

  -- jump
  require "plugins.leap",
  require "plugins.todo-comments",
  require "plugins.numb",

  -- nav
  require "plugins.snacks_nav",
  require "plugins.telescope", -- Required by some plugins
  require "plugins.yazi",

  -- dev
  require "plugins.mason",
  require "plugins.nvim-lspconfig",
  require "plugins.nvim-lint",
  require "plugins.conform",
  -- require "plugins.nvim-dap",
  -- require "plugins.neotest",

  -- git
  require "plugins.gitsigns",
  require "plugins.snacks_git",
  require "plugins.neogit",
  require "plugins.diffview",

  -- utils
  require "plugins.snacks_utils",
  require "plugins.persistence",
  require "plugins.guess-indent",
  require "plugins.nvim-deps",

  require "plugins.leetcode",

  -- languages
  -- lua
  require "plugins.lazydev",

  -- markdown
  require "plugins.render-markdown",
  require "plugins.markdown-preview",

  -- python
  require "plugins.venv-selector",
}
