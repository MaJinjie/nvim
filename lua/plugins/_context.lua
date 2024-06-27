---@type LazySpec
return {
  { "kylechui/nvim-surround", version = "*", event = "User AstroFile", opts = {} },
  {
    "Wansmer/treesj",
    cmd = "TSJToggle",
    opts = { use_default_keymaps = false },
    dependencies = {
      {
        "AstroNvim/astrocore",
        opts = {
          mappings = {
            n = {
              ["\\j"] = { "<Cmd> TSJToggle <Cr>", desc = "Toggle Treesitter Join" },
            },
          },
        },
      },
    },
  },
  { "terryma/vim-expand-region", event = { "User AstroFile" } },
}
