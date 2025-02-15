return {
  {
    "williamboman/mason.nvim",
    opts = { ensure_installed = { "bashls", "shellcheck", "shfmt", "beautysh" } },
  },
  { "neovim/nvim-lspconfig", opts = { servers = { bashls = true } } },
  {
    "stevearc/conform.nvim",
    opts = { formatters_by_ft = { sh = { "shfmt" } } },
  },
  {
    "mfussenegger/nvim-lint",
    opts = { linters_by_ft = { sh = { "shellcheck" } } },
  },
}
