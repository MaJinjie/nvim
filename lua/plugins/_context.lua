---@type LazySpec
return {
  { "kylechui/nvim-surround", version = "*", event = "VeryLazy", opts = {} },
  { "Wansmer/treesj", cmd = "TSJToggle", opts = { use_default_keymaps = false } },
  { "terryma/vim-expand-region", event = { "User AstroFile" } },
}
