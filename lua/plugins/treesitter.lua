return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
    build = ":TSUpdate",
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    keys = { "<c-space>", desc = "Treesitter Selection" },
    init = function()
      vim.keymap.set("n", "<leader>uT", function()
        require("util.keymap").toggle("Treesitter", function()
          local state = vim.b.ts_highlight
          if state then
            vim.treesitter.stop()
          else
            vim.treesitter.start()
          end
          return not state
        end)
      end, { desc = "Toggle Treesitter Context" })
    end,
    ---@type TSConfig
    ---@diagnostic disable-next-line: missing-fields
    opts = {
      highlight = { enable = true },
      indent = { enable = true },
      -- stylua: ignore
      ensure_installed = {
        "markdown", "markdown_inline",  -- markdown
        "html",
        "lua", "luadoc", "luap", -- lua
        "bash", -- shell
        "c", "cpp", "cmake",
        "make",
        "rust", -- rust
        "diff",
        "javascript",
        "jsdoc",
        "json",
        "jsonc",
        "printf",
        "python",
        "query",
        "regex",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
        "toml",
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-Space>",
          node_incremental = "<C-a>",
          scope_incremental = "<C-Space>",
          node_decremental = "<C-x>",
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["aF"] = "@function.outer",
            ["iF"] = "@function.inner",
            ["aC"] = "@class.outer",
            ["iC"] = "@class.inner",
            ["ac"] = "@conditional.outer",
            ["ic"] = "@conditional.inner",
            ["ao"] = "@loop.outer",
            ["io"] = "@loop.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = false,
          goto_next_start = {
            ["]f"] = "@function.outer",
            ["]c"] = "@class.outer",
            ["]a"] = "@parameter.inner",
          },
          goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
          goto_previous_start = {
            ["[f"] = "@function.outer",
            ["[c"] = "@class.outer",
            ["[a"] = "@parameter.inner",
          },
          goto_previous_end = {
            ["[F"] = "@function.outer",
            ["[C"] = "@class.outer",
            ["[A"] = "@parameter.inner",
          },
        },
      },
    },
    main = "nvim-treesitter.configs",
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "VeryLazy",
    -- stylua: ignore
    keys = {
      { "gt", function() require("treesitter-context").go_to_context(vim.v.count1) end, mode = { "n", "v" }, desc = "Goto Context" },
      { "gT", function() require("treesitter-context").go_to_context(math.huge) end, mode = { "n", "v" }, desc = "Goto Context Top" },
    },
    init = function()
      vim.keymap.set("n", "<leader>ut", function()
        require("util.keymap").toggle("Treesitter Context", function()
          local tsc = require("treesitter-context")
          local state = tsc.enabled()
          if state then
            tsc.disable()
          else
            tsc.enable()
          end
          return not state
        end)
      end, { desc = "Toggle Treesitter Context" })
    end,
    opts = { mode = "cursor", max_lines = 3 },
  },
}
