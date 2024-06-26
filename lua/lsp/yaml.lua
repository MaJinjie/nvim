return {
  {
    "b0o/SchemaStore.nvim",
    dependencies = {
      {
        "AstroNvim/astrolsp",
        opts = function(_, opts)
          local iterrator = require "uts.iterator"
          local user_opts = iterrator(opts, true)

          user_opts "force" {
            config = {
              yamlls = {
                on_new_config = function(config)
                  config.settings.yaml.schemas = vim.tbl_deep_extend(
                    "force",
                    config.settings.yaml.schemas or {},
                    require("schemastore").yaml.schemas()
                  )
                end,
                settings = { yaml = { schemaStore = { enable = false, url = "" } } },
              },
            },
          }
        end,
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        yaml = { { "prettierd", "prettier" } },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "yaml" })
      end
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "yamlls" })
    end,
  },
  {
    "jay-babu/mason-null-ls.nvim",
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "prettierd" })
    end,
  },
}
