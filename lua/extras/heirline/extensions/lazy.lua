return function()
  local stats = require("lazy").stats()
  local lazy_text = {
    provider = "Lazy 󰒲 ",
    hl = { fg = "blue" },
  }
  local loaded = {
    provider = ("loaded: %d/%d"):format(stats.loaded, stats.count),
    hl = { fg = "cyan" },
  }
  local startuptime = {
    provider = ("startuptime: %.2fms"):format(stats.startuptime),
    hl = { fg = "purple" },
  }

  return {
    lazy_text,
    loaded,
    startuptime,
    gap = 2,
  }
end
