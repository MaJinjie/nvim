---@type LazySpec
return {
  { "max397574/better-escape.nvim", event = "InsertCharPre", opts = { mapping = { "jk", "JK" }, timeout = 300 } },
  { "keaising/im-select.nvim", event = "InsertEnter", opts = {} },
  {
    "nguyenvukhang/nvim-toggler",
    dependencies = {
      {
        "AstroNvim/astrocore",
        opts = {
          mappings = {
            n = {
              ["<Bslash>i"] = { function() require("nvim-toggler").toggle() end, desc = "Toggle CursorWord" },
            },
          },
        },
      },
    },
    opts = { remove_default_keybinds = true },
  },
}
