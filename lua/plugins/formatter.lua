return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = {
        -- Conform will run multiple formatters sequentially
        python = { "isort", "black" },
        -- Use a sub-list to run only the first available formatter
        javascript = { { "prettierd", "prettier" } },
        xml = { "xmlformat" },
        cpp = { "clang-format" }
      }
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    opts = {
      indent = {
        char = "│",
        tab_char = "│",
      },
      scope = { enabled = true },
      exclude = {
        filetypes = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",
          "Trouble",
          "trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
          "dragram"
        },
      },
    },
    main = "ibl",
  }
}
