return {
  "folke/lazydev.nvim",
  ft = "lua",
  cmd = "LazyDev",
  opts = {
    library = {
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      { path = "snacks.nvim", words = { "Snacks" } },
      { path = "yazi-meta.nvim", words = { "ya", "cx" } },
    },
  },
  specs = {
    "saghen/blink.cmp",
    opts = function(_, opts)
      local cmp = require("blink-cmp")
      cmp.add_filetype_source("lua", "lazydev")

      opts.sources.providers["lazydev"] = {
        name = "LazyDev",
        module = "lazydev.integrations.blink",
        score_offset = 100,
      }
      return opts
    end,
  },
}
