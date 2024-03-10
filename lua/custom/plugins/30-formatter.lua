return {
  "mhartington/formatter.nvim",
  -- Provides the Format, FormatWrite, FormatLock, and FormatWriteLock commands
  cmd = { "Format", "FormatWrite" },
  config = function(_, opts)
    local util = require "formatter.util"
    -- filetype_default_formatters
    local fdf = require "formatter.filetypes"

    require("formatter").setup {
      logging = true,
      log_level = vim.log.levels.WARN,
      -- 应该返回一个函数表，按照顺序执行可用的格式化函数
      -- 如何自定义配置 https://github.com/mhartington/formatter.nvim
      filetype = {
        lua = { fdf.lua.stylua },
        c = { fdf.c.clangformat },
        cpp = { fdf.cpp.clangformat },
        cmake = { fdf.cmake.cmakeformat },
      },
    }
  end,
}
