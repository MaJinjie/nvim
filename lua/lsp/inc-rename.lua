return {
  "smjonas/inc-rename.nvim",
  event = "User AstroLspSetup",
  opts = function(_, opts)
    local is_available = require("astrocore").is_available
    if is_available "dressing.nvim" and not is_available "noice.nvim" then opts.input_buffer_type = "dressing" end
  end,
}
