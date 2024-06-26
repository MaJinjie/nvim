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
  dependencies = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local iterator = require "uts.iterator"
        local mappings = iterator(opts.mappings, false)

        mappings "n" {
          ["<Leader>fr"] = {
            function() require("spectre").open_file_search { select_word = true } end,
            desc = "Spectre (current file)",
          },
          ["<Leader>fR"] = {
            function() require("spectre").open { select_word = true } end,
            desc = "Spectre",
          },
        }
      end,
    },
  },
}
