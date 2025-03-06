User.keymap.toggle["<leader>ub"] = function()
  local rd = User.util.lazy_require("rainbow-delimiters")
  return Snacks.toggle({
    name = "RainBow Delimiters",
    get = function()
      return rd.is_enabled(0)
    end,
    set = function(state)
      if state then
        rd.enable(0)
      else
        rd.disable(0)
      end
    end,
  })
end

return {
  "HiPhish/rainbow-delimiters.nvim",
  event = "LazyFile",
  opts = {},
  config = function(_, opts)
    require("rainbow-delimiters.setup").setup(opts)
    require("rainbow-delimiters").enable(0)
  end,
}
