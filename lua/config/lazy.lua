require("config.options")
require("config.keymaps")
require("config.autocmds")

require("lazy").setup({
  { import = "plugins" },
  { import = "plugins.lang" },
}, { change_detection = { notify = false } })

require("util").on_very_lazy(function()
  vim.defer_fn(function()
    require("lazy").load({
      plugins = vim.tbl_filter(function(plugin_name)
        return not package.loaded[plugin_name]
      end, vim.g.defer_load_plugins),
    })
  end, 50)
end)
