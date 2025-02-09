return {
  {
    "williamboman/mason.nvim",
    opts = { ensure_installed = { "basedpyright", "ruff", "debugpy" } },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      ---@type table<string,lspconfig.Config|{}>
      servers = {
        basedpyright = {
          settings = {
            basedpyright = {
              disableOrganizeImports = true,
              analysis = {
                -- Ignore all files for analysis to exclusively use Ruff for linting
                ignore = { "*" },
                autoImportCompletions = true,
                typeCheckingMode = "basic",
                diagnosticSeverityOverrides = {
                  reportUnusedImport = "information",
                  reportUnusedFunction = "information",
                  reportUnusedVariable = "information",
                  reportGeneralTypeIssues = "none",
                  reportOptionalMemberAccess = "none",
                  reportOptionalSubscript = "none",
                  reportPrivateImportUsage = "none",
                },
              },
            },
          },
        },
        ruff = {
          init_options = {
            settings = {},
          },
          on_attach = function(client)
            client.server_capabilities.hoverProvider = false
          end,
        },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = {
          "ruff_fix", -- To fix auto-fixable lint errors.
          "ruff_format", -- To run the Ruff formatter.
          "ruff_organize_imports", -- To organize the imports.
        },
      },
    },
  },
  -- 以及使用ruff作为lsp
  -- {
  --   "mfussenegger/nvim-lint",
  --   opts = { linters_by_ft = { python = { "ruff" } } },
  -- },
  {
    "linux-cultist/venv-selector.nvim",
    branch = "regexp",
    keys = {
      { "<localleader>v", "<Cmd>VenvSelect<CR>", ft = "python", desc = "Select VirtualEnv" },
    },
    opts = {},
    cmd = "VenvSelect",
  },
}
