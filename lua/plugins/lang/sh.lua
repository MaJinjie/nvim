return {
  {
    "williamboman/mason.nvim",
    opts = { ensure_installed = { "bashls", "shellcheck", "shfmt" } },
  },
  { "neovim/nvim-lspconfig", opts = { bashls = true } },
  {
    "stevearc/conform.nvim",
    opts = { formatters_by_ft = { sh = { "shfmt" } } },
  },
  {
    "mfussenegger/nvim-lint",
    linters_by_ft = { sh = "shellcheck" },
  },
}
