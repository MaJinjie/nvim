return {
  { "williamboman/mason.nvim", opts = { ensure_installed = { "clangd", "clang-format" } } },
  {
    "neovim/nvim-lspconfig",
    opts = {
      ---@type lspconfig.Config|{}|boolean
      clangd = {
        -- stylua: ignore
        keys = {
          { "n", "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", has = "textDocument/switchSourceHeader", cond = function(_, bufnr) return vim.api.nvim_buf_get_commands(bufnr, { builtin = false })["ClangdSwitchSourceHeader"] end, { desc = "Switch Source/Header" } },
          { "n", "<leader>ci", "<cmd>ClangdShowSymbolInfo<cr>", has = "textDocument/symbolInfo", cond = function(_, bufnr) return vim.api.nvim_buf_get_commands(bufnr, { builtin = false })["ClangdShowSymbolInfo"] end, { desc = "Show Symbol Info" } },
        },
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=never",
          "--completion-style=detailed",
          "--function-arg-placeholders",
          "--fallback-style=llvm",
          "--pch-storage=memory",
          "--limit-results=100",
        },
      },
    },
  },

  {
    "Civitasv/cmake-tools.nvim",
    ft = { "cmake" },
    opts = {},
  },
  {
    "mfussenegger/nvim-dap",
    opts = {
      configurations = {
        cpp = {
          {
            name = "Launch file",
            type = "codelldb",
            request = "launch",
            program = function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
          },
        },
      },
    },
  },
}

-- {
--   "p00f/clangd_extensions.nvim",
--   lazy = true,
--   opts = {
--     inlay_hints = { inline = false },
--     ast = {
--       --These require codicons (https://github.com/microsoft/vscode-codicons)
--       role_icons = {
--         type = "",
--         declaration = "",
--         expression = "",
--         specifier = "",
--         statement = "",
--         ["template argument"] = "",
--       },
--       kind_icons = {
--         Compound = "",
--         Recovery = "",
--         TranslationUnit = "",
--         PackExpansion = "",
--         TemplateTypeParm = "",
--         TemplateTemplateParm = "",
--         TemplateParamObject = "",
--       },
--     },
--   },
-- },
