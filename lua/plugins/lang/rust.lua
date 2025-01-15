return {
  { "williamboman/mason.nvim", opts = { ensure_installed = { "codelldb" } } },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        rust_analyzer = function(_, default_opts)
          local server = {
            on_attach = default_opts.on_attach,
            default_settings = {
              -- rust-analyzer language server configuration
              ["rust-analyzer"] = {
                cargo = {
                  allFeatures = true,
                  loadOutDirsFromCheck = true,
                  buildScripts = {
                    enable = true,
                  },
                },
                -- Add clippy lints for Rust if using rust-analyzer
                checkOnSave = true,
                -- Enable diagnostics if using rust-analyzer
                diagnostics = {
                  enable = true,
                },
                procMacro = {
                  enable = true,
                  ignored = {
                    ["async-trait"] = { "async_trait" },
                    ["napi-derive"] = { "napi" },
                    ["async-recursion"] = { "async_recursion" },
                  },
                },
                files = {
                  excludeDirs = {
                    ".direnv",
                    ".git",
                    ".github",
                    ".gitlab",
                    "bin",
                    "node_modules",
                    "target",
                    "venv",
                    ".venv",
                  },
                },
              },
            },
          }
          vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, { server = server })
        end,
      },
    },
  },
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    opts = {
      lsp = {
        enabled = true,
        on_attach = function(client, bufnr)
          -- the same on_attach function as for your other lsp's
        end,
        actions = true,
        completion = true,
        hover = true,
      },
    },
  },
  {
    "mrcjkb/rustaceanvim",
    dependencies = "neovim/nvim-lspconfig",
    version = "^5",
    ft = "rust",
    config = function(_, opts)
      local package_path = require("mason-registry").get_package("codelldb"):get_install_path()
      local codelldb = package_path .. "/extension/adapter/codelldb"
      local library_path = package_path .. "/extension/lldb/lib/liblldb.dylib"
      local uname = vim.uv.os_uname().sysname
      if uname == "Linux" then
        library_path = package_path .. "/extension/lldb/lib/liblldb.so"
      end
      opts.dap = {
        adapter = require("rustaceanvim.config").get_codelldb_adapter(codelldb, library_path),
      }
      vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts or {})
    end,
  },
}
