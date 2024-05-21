return {
  "rcarriga/nvim-notify",
  opts = function(_, opts)
    local user_opts = {
      stages = "static",
      -- render = "compact",
      fps = 5,
      timeout = 1800,
    }
    return require("astrocore").extend_tbl(opts, user_opts)
  end,
}
