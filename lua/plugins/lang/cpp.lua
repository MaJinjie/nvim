return {
  { "williamboman/mason.nvim", opts = { ensure_installed = { "clangd", "clang-format", "codelldb" } } },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ---@module 'lspconfig'
        ---@type lspconfig.Config|{_?:util.lsp.Opts}
        clangd = {
          on_attach = function(client, bufnr)
            --stylua: ignore
            local keymaps = {
              ["textDocument/symbolInfo"] = { "n", "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", { desc = "Switch Source/Header", buffer = bufnr } },
              ["textDocument/switchSourceHeader"] = { "n", "<leader>ci", "<cmd>ClangdShowSymbolInfo<cr>", { desc = "Show Symbol Info", buffer = bufnr } },
            }
            for method, keymap in pairs(keymaps) do
              if client.supports_method(method, { bufnr = bufnr }) then
                vim.keymap.set(unpack(keymap))
              end
            end
          end,
          cmd = {
            "clangd",
            "--background-index",
            "--background-index-priority=normal",
            "--clang-tidy",
            "--header-insertion=never",
            "--completion-style=bundled",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
            "--pch-storage=memory",
            "--limit-results=100",
          },
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
