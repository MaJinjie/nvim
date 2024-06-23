---@type LazySpec
return {
  { "kevinhwang91/nvim-hlslens", event = "User AstroFile", opts = {} },
  {
    "chentoast/marks.nvim",
    event = "User AstroFile",
    opts = { excluded_filetypes = { "qf", "NvimTree", "toggleterm", "TelescopePrompt", "alpha", "netrw", "neo-tree" } },
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "User AstroFile",
    cmd = "TSContextToggle",
  },
}
