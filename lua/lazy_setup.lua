local lazy_spec = {
  {
    "AstroNvim/AstroNvim",
    import = "astronvim.plugins",
    opts = {
      mapleader = " ", -- This ensures the leader key must be configured before Lazy is set up
      maplocalleader = " ", -- This ensures the localleader key must be configured before Lazy is set up
    },
  },
  { import = "ui" },
  { import = "core" },
  { import = "lsp" },
  { import = "plugins" },
}

local lazy_config = {
  defaults = { lazy = true },
} --[[@as LazyConfig]]

require("lazy").setup(lazy_spec, lazy_config)
