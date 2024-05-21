return {

  {
    --n: <Tab> <S-Tab> <CR> q o r R C ti tu th tl
    import = "astrocommunity.project.nvim-spectre", -- nvim-pack/nvim-spectre
  },
  {
    "nvim-pack/nvim-spectre",
    opts = function(_, opts)
      local user_opts = {
        mapping = {
          send_to_qf = { map = "q" },
          show_option_menu = { map = "o" },
          change_view_mode = { map = "v" },

          replace_cmd = { map = "C" },
          run_current_replace = { map = "r" },
          run_replace = { map = "R" },
          resume_last_search = { map = "tl" },
        },
      }
      return require("astrocore").extend_tbl(opts, user_opts)
    end,
  },
}
