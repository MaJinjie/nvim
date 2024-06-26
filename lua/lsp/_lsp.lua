return {
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    ---@diagnostic disable: missing-fields
    opts = {
      features = {
        autoformat = true, -- enable or disable auto formatting on start
        codelens = true, -- enable/disable codelens refresh on start
        inlay_hints = false, -- enable/disable inlay hints on start
        semantic_tokens = true, -- enable/disable semantic token highlighting
      },
      formatting = { format_on_save = { enabled = true } },
      config = {},
      flags = {},
      servers = {},
      autocmds = {},
      commands = {},
      handlers = {},
      mappings = {
        n = {
          ["<Leader>lr"] = {
            function() return ":IncRename " .. vim.fn.expand "<cword>" end,
            expr = true,
            desc = "Rename current symbol",
            cond = "textDocument/rename",
          },

          ["[e"] = {
            function() require("treesitter-context").go_to_context(vim.v.count1) end,
            desc = "Backward context",
          },
          ["<Leader>uE"] = { "<Cmd> TSContextToggle <Cr>", desc = "Toggle context display" },
        },
      },
      on_attach = nil,
      capabilities = {},
      lsp_handlers = {},
    },
  },
  { "smjonas/inc-rename.nvim", event = "User AstroLspSetup", opts = {} },
  { "lukas-reineke/headlines.nvim", ft = { "markdown", "norg", "org", "rmd" }, opts = {} },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "User AstroFile",
    cmd = "TSContextToggle",
    opts = {
      multiline_threshold = 1,
    },
  },
  {
    "RRethy/nvim-treesitter-endwise",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter", opts = function(_, opts) opts.endwise = { enable = true } end },
    },
  },
  { "f-person/git-blame.nvim", event = "User AstroGitFile" },
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = { "mfussenegger/nvim-dap", "nvim-treesitter/nvim-treesitter" },
    event = "User AstroFile",
    opts = { commented = true, enabled = true, enabled_commands = true },
  },
  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    event = "LspAttach",
    dependencies = {
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          local iterator = require "uts.iterator"
          local mappings, user_opts = iterator(opts.mappings, false), iterator(opts, true)
          mappings "n" {
            ["<Leader>uD"] = {
              function() require("lsp_lines").toggle() end,
              desc = "Toggle virtual diagnostic lines",
            },
          }
          user_opts "force" {
            diagnostics = {
              virtual_text = false,
            },
          }
        end,
      },
    },
    opts = {},
  },
}
