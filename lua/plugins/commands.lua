return {
  {
    "FeiyouG/commander.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    keys = {
      { "<leader>p", "<CMD>Telescope commander<CR>", mode = "n" },
    },
    config = function()
      require("commander").setup({
        components = {
          "DESC",
          "KEYS",
          "CAT",
        },
        sort_by = {
          "DESC",
          "KEYS",
          "CAT",
          "CMD"
        },
        integration = {
          telescope = {
            enable = true,
          },
          lazy = {
            enable = true,
            set_plugin_name_as_cat = true
          }
        }
      })
    end,
  }
}


-- integrating commander.nvim with lazy.nvim
-- This command will be added to commander automatically
-- commander = {
--   {
--     cmd = "<CMD>GenTocGFM<CR>",
--     desc = "Generate table of contents (GFM)",
--   }
-- },
