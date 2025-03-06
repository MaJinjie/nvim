User.keymap.toggle["<leader>uM"] = function()
  return Snacks.toggle({
    name = "Render Markdown",
    get = function()
      return require("render-markdown.state").enabled
    end,
    set = function(enabled)
      local m = require("render-markdown")
      if enabled then
        m.enable()
      else
        m.disable()
      end
    end,
  })
end

return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown", "norg", "rmd", "org", "codecompanion" },
  opts = {
    code = {
      width = "block",
      right_pad = 1,
    },
  },
}
