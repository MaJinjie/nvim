return {
  {
    "robitx/gp.nvim",
    config = function()
      require("gp").setup {
        curl_params = { '--proxy', 'socks5://qlyun:qlyun@54.242.216.72:3636' },
      }
    end,
  }
}
