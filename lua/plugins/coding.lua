local theme = require("config.theme")
return {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      map_c_w = true,
    },
  },
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    -- 防止和Leap冲突
    opts = { move_cursor = "sticky", keymaps = { visual = "gs", visual_line = "gS" } },
  },
  {
    "saghen/blink.cmp",
    version = "*",
    dependencies = "rafamadriz/friendly-snippets",
    event = { "InsertEnter", "CmdlineEnter" },
    build = "cargo build --release",
    init = function() end,
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = "none",
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "cancel", "fallback" },
        ["<C-y>"] = { "select_and_accept", "fallback" },
        ["<esc>"] = { "hide", "fallback" },
        ["<cr>"] = { "accept", "fallback" },

        ["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },

        ["<Up>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "show" },
        ["<C-n>"] = { "select_next", "show" },

        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
        cmdline = {
          ["<C-space>"] = { "show", "hide" },
          ["<C-e>"] = { "cancel", "fallback" },
          ["<C-y>"] = { "select_and_accept", "fallback" },
          ["<Tab>"] = { "select_next", "fallback" },
          ["<S-Tab>"] = { "select_prev", "fallback" },
        },
      },
      completion = {
        keyword = {},
        trigger = {},
        accept = { auto_brackets = { enabled = true } },
        list = { max_items = 20, selection = { preselect = false, auto_insert = true } },
        menu = {
          winblend = vim.o.winblend,
          draw = {
            treesitter = { "lsp" },
            columns = { { "kind_icon" }, { "label", "label_description", gap = 1 }, { "source_name" } },
            components = {
              source_name = {
                width = { max = 30 },
                text = function(ctx)
                  return "[" .. ctx.source_name .. "]"
                end,
                highlight = "PreCondit",
              },
            },
          },
        },
        documentation = { window = { winblend = vim.o.winblend } },
        ghost_text = { enabled = true },
      },
      appearance = { kind_icons = theme.icons.lsp_symbol },
      signature = { enabled = false },
      snippets = {
        preset = "default",
      },

      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        per_filetype = {
          lua = { "lsp", "path", "snippets", "buffer", "lazydev" },
          markdown = { "lsp", "path", "snippets", "buffer", "render_markdown" },
        },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 10,
          },
          render_markdown = {
            name = "RenderMarkdown",
            module = "render-markdown.integ.blink",
            score_offset = 10,
            fallbacks = { "lsp" },
          },
        },
      },
    },
  },
  --- usage:
  ---   - 允许定义全局和语言特定代码段
  ---   - 支持精确匹配和模糊匹配
  ---   - 支持vim.ui.select从多个匹配的片段中选择
  ---   - 支持嵌套的会话
  ---   - 支持*.json, *.lua定义代码片段
  -- {
  --   "echasnovski/mini.snippets",
  --   lazy = true,
  --   version = false,
  --   config = function()
  --     local mini = require("mini.snippets")
  --     mini.setup({
  --       snippets = {
  --         -- Load custom file with global snippets first (adjust for Windows)
  --         -- gen_loader.from_file("~/.config/nvim/snippets/global.json"),
  --
  --         -- Load snippets based on current language by reading files from
  --         -- "snippets/" subdirectories from 'runtimepath' directories.
  --         -- mini.gen_loader.from_lang(),
  --       },
  --     })
  --   end,
  -- },
}
