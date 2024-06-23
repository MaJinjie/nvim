---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = { "RRethy/nvim-treesitter-endwise" },
  opts = {
    -- stylua: ignore
    ensure_installed = {
      "rust", "cpp", "c",
      "vim", "lua",
      "bash",
      "toml", "yaml", "hyprlang",
      "markdown", "markdown_inline",
      "regex",
      "html",
    },
    endwise = { enable = true },
  },
}
