---@type LazySpec
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
      mappings = {},
      on_attach = nil,
      capabilities = {},
      lsp_handlers = {},
    },
  },
  {
    "smjonas/inc-rename.nvim",
    event = "User AstroLspSetup",
    opts = {},
    dependencies = {
      {
        "AstroNvim/astrolsp",
        opts = {
          mappings = {
            n = {
              ["<Leader>lr"] = {
                function() return ":IncRename " .. vim.fn.expand "<cword>" end,
                expr = true,
                desc = "Rename current symbol",
                cond = "textDocument/rename",
              },
            },
          },
        },
      },
    },
  },
  { "lukas-reineke/headlines.nvim", ft = { "markdown", "norg", "org", "rmd" }, opts = {} },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "User AstroFile",
    cmd = "TSContextToggle",
    opts = {
      multiline_threshold = 1,
    },
    dependencies = {
      {
        "AstroNvim/astrolsp",
        opts = {
          mappings = {
            n = {
              ["[e"] = {
                function() require("treesitter-context").go_to_context(vim.v.count1) end,
                desc = "Backward context",
              },
              ["<Leader>uE"] = { "<Cmd> TSContextToggle <Cr>", desc = "Toggle context display" },
            },
          },
        },
      },
    },
  },
  {
    "RRethy/nvim-treesitter-endwise",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter", opts = { endwise = { enable = true } } },
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
        opts = {
          mappings = {
            n = {
              ["<Leader>uD"] = {
                function() require("lsp_lines").toggle() end,
                desc = "Toggle virtual diagnostic lines",
              },
            },
          },
        },
      },
    },
    opts = {},
  },
}
