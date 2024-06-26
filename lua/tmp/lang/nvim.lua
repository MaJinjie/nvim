-- add the cmp source for completion of:
-- `require "modname"`
-- `---@module "modname"`
return {
  { "folke/neodev.nvim", enabled = false },
  { "Bilal2453/luvit-meta" },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    cmd = "LazyDev",
    opts = {
      library = {
        { path = "luvit-meta/library", words = { "vim%.uv" } },
        { path = "astrocore", words = { "AstroCore" } },
        { path = "astrolsp", words = { "AstroLSP" } },
        { path = "astroui", words = { "AstroUI" } },
        { path = "astrotheme", words = { "AstroTheme" } },
        { path = "lazy.nvim", words = { "Lazy" } },
      },
    },
  },
}
