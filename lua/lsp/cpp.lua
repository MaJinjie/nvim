local uname = (vim.uv or vim.loop).os_uname()
local is_linux_arm = uname.sysname == "Linux" and (uname.machine == "aarch64" or vim.startswith(uname.machine, "arm"))
return {
  {
    "AstroNvim/astrolsp",
    opts = function(_, opts)
      local iterator = require "uts.iterator"
      local user_opts = iterator(opts, true)

      user_opts "force" {
        clangd = {
          capabilities = {
            offsetEncoding = "utf-8",
          },
        },
      }

      if is_linux_arm then opts.servers = require("astrocore").list_insert_unique(opts.servers, { "clangd" }) end
    end,
  },
  {
    "p00f/clangd_extensions.nvim",
    dependencies = {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local iterator = require "uts.iterator"
        local user_opts = iterator(opts, false)

        user_opts "autocmds" {
          clangd_extensions = {
            {
              event = "LspAttach",
              desc = "Load clangd_extensions with clangd",
              callback = function(args)
                if assert(vim.lsp.get_client_by_id(args.data.client_id)).name == "clangd" then
                  require "clangd_extensions"
                  vim.api.nvim_del_augroup_by_name "clangd_extensions"
                end
              end,
            },
          },
          clangd_extension_mappings = {
            {
              event = "LspAttach",
              desc = "Load clangd_extensions with clangd",
              callback = function(args)
                if assert(vim.lsp.get_client_by_id(args.data.client_id)).name == "clangd" then
                  require("astrocore").set_mappings({
                    n = {
                      ["<Leader>lw"] = { "<Cmd>ClangdSwitchSourceHeader<CR>", desc = "Switch source/header file" },
                    },
                  }, { buffer = args.buf })
                end
              end,
            },
          },
        }
      end,
    },
  },
  {
    "Civitasv/cmake-tools.nvim",
    ft = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
    opts = {},
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed =
          require("astrocore").list_insert_unique(opts.ensure_installed, { "cpp", "c", "objc", "cuda", "proto" })
      end
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = function(_, opts)
      if not is_linux_arm then
        opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "clangd" })
      end
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "codelldb" })
    end,
  },
}
