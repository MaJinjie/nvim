return {
  {
    "FeiyouG/commander.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    keys = {
      { "<leader><leader>", "<CMD>Telescope commander<CR>", nowait = true },
    },
    config = function()
      require("commander").setup {
        components = {
          "CAT",
          "DESC",
          "KEYS",
        },
        sort_by = {
          "CAT",
          "DESC",
          -- "KEYS",
          -- "CMD"
        },
        integration = {
          telescope = {
            enable = true,
          },
          lazy = {
            -- enable = true,
            -- set_plugin_name_as_cat = true
          },
        },
      }

      local data = require("custom.plugins.configs.commander").Data

      for _, items in pairs(data) do
        require("commander").add(items, items.opts)
      end
    end,
  },
}
