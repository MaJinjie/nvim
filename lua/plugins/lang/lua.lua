return {
  {
    "williamboman/mason.nvim",
    opts = { ensure_installed = { "lua_ls", "stylua", "selene" } },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              workspace = { checkThirdParty = false },
              codeLens = { enable = true },
              doc = { privateName = { "^_" } },
              completion = { callSnippet = "Replace", keywordSnippet = "Both" },
              format = { enable = false },
              diagnostics = { enable = true },
              hint = {
                enable = true,
                paramType = true,
                paramName = "Disable",
                semicolon = "Disable",
                arrayIndex = "Disable",
              },
            },
          },
        },
      },
    },
  },
  { "stevearc/conform.nvim", opts = { formatters_by_ft = { lua = { "stylua" } } } },
}
