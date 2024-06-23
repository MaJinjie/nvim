---@type LazySpec
return {
  {
    "williamboman/mason-lspconfig.nvim",
    -- stylua: ignore
    opts = {
      ensure_installed = {
        "lua_ls",
        "taplo",
        "yamlls",
        "marksman",
      },
    },
  },
  {
    "jay-babu/mason-null-ls.nvim",
    -- stylua: ignore
    opts = {
      ensure_installed = {
        "stylua", "selene",
        "prettierd",
      },
    },
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    -- stylua: ignore
    opts = {
      ensure_installed = {
        "codelldb",
      },
    },
  },
}
