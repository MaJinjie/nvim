require("config.options")
require("config.keymaps")
require("config.autocmds")

require("lazy").setup({
  { import = "plugins" },
  { import = "plugins.lang" },
}, { change_detection = { notify = false } })
