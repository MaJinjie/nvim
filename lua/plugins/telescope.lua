return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = { "nvim-telescope/telescope-fzf-native.nvim" },
    opts = function()
      local actions = require "telescope.actions"
      return {
        defaults = {
          layout_strategy = "flex",
          sorting_strategy = "ascending",
          dynamic_preview_title = true,
          mappings = {
            i = {
              ["<C-s>"] = actions.select_horizontal,
              ["<C-v>"] = actions.select_vertical,
              ["<C-t>"] = actions.select_tab,

              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-n>"] = actions.cycle_history_next,
              ["<C-p>"] = actions.cycle_history_prev,

              ["<A-?>"] = actions.which_key,
              ["<A-a>"] = actions.toggle_all,
            },
          },
        },
      }
    end,
  },
  { "nvim-telescope/telescope-fzf-native.nvim", lazy = true, build = "make" },
}
