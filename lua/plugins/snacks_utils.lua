return {
  "folke/snacks.nvim",
  opts = {
    bigfile = { enabled = true },
  },
  -- stylua: ignore
  keys = {
    { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
    { "<leader>f.",  function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
    { "<leader>dps", function() Snacks.profiler.scratch() end, desc = "Profiler Scratch Buffer" },
  },
  init = function()
    User.util.on_lazyload("snacks.nvim", function()
      _G.dd = Snacks.debug.inspect
      _G.log = Snacks.debug.log
    end)
  end,
}
