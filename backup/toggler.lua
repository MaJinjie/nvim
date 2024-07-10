---@type LazySpec
return {

  "nguyenvukhang/nvim-toggler",
  dependencies = {
    {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          n = {
            ["<Leader>i"] = { function() require("nvim-toggler").toggle() end, desc = "Toggle CursorWord" },
          },
        },
      },
    },
  },
  opts = { remove_default_keybinds = true },
}
