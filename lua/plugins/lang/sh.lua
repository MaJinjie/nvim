return {
   {
      "nvim-treesitter/nvim-treesitter",
      opts = { ensure_installed = { "bash" } },
   },
   {
      "neovim/nvim-lspconfig",
      opts = {
         servers = {
            bashls = {},
         },
      },
   },
   {
      "mfussenegger/nvim-lint",
      opts = {
         linters_by_ft = {
            sh = { "shellcheck" },
         },
      },
   },
   {
      "williamboman/mason.nvim",
      opts = { ensure_installed = { "shellcheck", "bash-debug-adapter" } },
   },
}
