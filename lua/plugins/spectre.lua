---@type LazyPluginSpec
return {
  "nvim-pack/nvim-spectre",
  cmd = "Spectre",
  opts = {
    mapping = {
      send_to_qf = { map = "q" },
      show_option_menu = { map = "o" },
      change_view_mode = { map = "v" },

      replace_cmd = { map = "C" },
      run_current_replace = { map = "r" },
      run_replace = { map = "R" },
      resume_last_search = { map = "L" },
    },
  },
  specs = {
    "AstroNvim/astrocore",
    opts = function()
      local map = require("utils").keymap.set

      map.n {
        ["<Leader>sr"] = {
          function() require("spectre").open_file_search { select_word = true } end,
          desc = "[spectre] curfile",
        },
        ["<Leader>sR"] = {
          function() require("spectre").open { select_word = true } end,
          desc = "[spectre] workspace",
        },
      }
    end,
  },
}
