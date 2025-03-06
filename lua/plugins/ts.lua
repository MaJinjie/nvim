-- Treesitter is a new parser generator tool that we can
-- use in Neovim to power faster and more accurate
-- syntax highlighting.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
    event = "VeryFile",
    build = ":TSUpdate",
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    keys = { { "<c-space>", desc = "Treesitter Selection" } },
    ---@module 'nvim-treesitter'
    ---@type TSConfig|{}
    opts = {
      highlight = { enable = true },
      indent = { enable = true },
      ensure_installed = {
        "bash",
        "c",
        "diff",
        "html",
        "javascript",
        "jsdoc",
        "json",
        "jsonc",
        "json5",
        "luadoc",
        "luap",
        "markdown",
        "markdown_inline",
        "printf",
        "python",
        "query",
        "regex",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
        "hyprlang",
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-Space>",
          node_incremental = "<Enter>",
          scope_incremental = "<C-Space>",
          node_decremental = "<BackSpace>",
        },
      },
      textobjects = {
        move = {
          enable = true,
          set_jumps = false,
          goto_next_start = {
            ["]f"] = "@function.outer",
            ["]c"] = "@class.outer",
            ["]a"] = "@parameter.inner",
            ["]o"] = "@block.inner",
          },
          goto_next_end = {
            ["]F"] = "@function.outer",
            ["]C"] = "@class.outer",
            ["]A"] = "@parameter.outer",
            ["]O"] = "@block.outer",
          },
          goto_previous_start = {
            ["[f"] = "@function.outer",
            ["[c"] = "@class.outer",
            ["[a"] = "@parameter.inner",
            ["[o"] = "@block.inner",
          },
          goto_previous_end = {
            ["[F"] = "@function.outer",
            ["[C"] = "@class.outer",
            ["[A"] = "@parameter.inner",
            ["[O"] = "@block.outer",
          },
        },
      },
    },
    ---@param opts TSConfig
    config = function(_, opts)
      opts.ensure_installed = User.util.dedup(opts.ensure_installed --[=[@as string[]]=])
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    lazy = true,
    -- keys = {
    --   { "H", desc = "Repeat last move previous" },
    --   { "L", desc = "Repeat last move next" },
    -- },
    -- config = function()
    --   local ts_repeat_move = require "nvim-treesitter.textobjects.repeatable_move"

    --   vim.keymap.set({ "n", "x", "o" }, "H", ts_repeat_move.repeat_last_move_previous)
    --   vim.keymap.set({ "n", "x", "o" }, "L", ts_repeat_move.repeat_last_move_next)
    -- end,
  },
}
