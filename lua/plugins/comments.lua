return {
  -- Neovim treesitter plugin for setting the commentstring based on the cursor location in a file.
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    event = "LazyFile",
    opts = {},
  },
  -- Smart and powerful comment plugin for neovim. Supports treesitter, dot repeat, left-right/up-down motions, hooks, and more
  {
    "numToStr/Comment.nvim",
    event = "LazyFile",
    opts = function()
      return {
        ignore = "^$",
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      }
    end,
  },
  -- {
  --   "s1n7ax/nvim-comment-frame",
  --   opts = { disable_default_keymap = true },
  --   keys = {
  --     { "<leader>"}
  --   },
  -- },
}
