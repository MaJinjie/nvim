return {
  {
    "nvim-pack/nvim-spectre",
    cmd = "Spectre",
    dependencies = {
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          local maps = opts.mappings
          local prefix = "<Leader>s"
          maps.n[prefix .. "w"] = { function() require("spectre").open() end, desc = "Spectre" }
          maps.n[prefix .. "f"] =
            { function() require("spectre").open_file_search() end, desc = "Spectre (current file)" }

          maps.x["w"] = {
            function() require("spectre").open_visual { select_word = true } end,
            desc = "Spectre (current word)",
          }
        end,
      },
    },
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
  },
}
