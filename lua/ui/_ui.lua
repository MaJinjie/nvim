---@type LazySpec
return {
  {
    "AstroNvim/astroui",
    ---@type AstroUIOpts
    opts = {
      colorscheme = "catppuccin",
      highlights = {
        init = {
          Search = { fg = "#c8d3f5", bg = "#3e68d7" },
          IncSearch = { fg = "#1b1d2b", bg = "#ff966c" },
          MsgArea = { fg = "#828bb8" },
          NormalFloat = { fg = "#c8d3f5", bg = "#1e2030" },

          CmpItemAbbrMatch = { bg = "NONE", fg = "#569CD6" },
          CmpItemAbbrMatchFuzzy = { link = "CmpIntemAbbrMatch" },
          CmpItemMenu = { fg = "#545c7e", bg = "NONE", italic = true },

          FlashLabel = { fg = "#c8d3f5", bg = "#ff007c" },
          TreesitterContextLineNumber = { link = "Constant" },
        },
      },
      icons = {
        Trouble = "󱍼",
      },
      status = {},
      text_icons = {},
    },
  },
  {
    "kevinhwang91/nvim-hlslens",
    event = "User AstroFile",
    opts = {},
    dependencies = { { "AstroNvim/astrocore", opts = { on_keys = { auto_hlsearch = false } } } },
  },
  {
    "chentoast/marks.nvim",
    event = "User AstroFile",
    opts = { excluded_filetypes = { "qf", "NvimTree", "toggleterm", "TelescopePrompt", "alpha", "netrw", "neo-tree" } },
  },
  {
    "lewis6991/satellite.nvim",
    event = "User AstroFile",
    opts = {
      current_only = true,
      excluded_filetypes = { "prompt", "TelescopePrompt", "noice", "notify", "neo-tree", "aerial" },
    },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    opts = function(_, opts) opts.scope = { show_start = false, show_end = true } end,
  },
  {
    "rcarriga/nvim-notify",
    opts = function(_, opts)
      local iterator = require "uts.iterator"
      local user_opts = iterator(opts, true)

      user_opts "force" {
        stages = "slide",
        fps = 5,
        timeout = 1200,
      }

      opts.stages = "static"
      vim.print(opts)
    end,
  },
}
