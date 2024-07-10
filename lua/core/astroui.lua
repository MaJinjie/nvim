---@type LazySpec
return {
  {
    "AstroNvim/astroui",
    ---@type AstroUIOpts
    opts = {
      colorscheme = "catppuccin",
      highlights = {
        init = {},
        ["catppuccin-mocha"] = function()
          local keys = {}
          local highlights = setmetatable({}, {
            __newindex = function(_t, _k, _v)
              if vim.tbl_contains(keys, _k) then
                vim.notify(tostring(_k) .. " is repeat", vim.log.levels.WARN)
              else
                for k, v in pairs(_v) do
                  rawset(_t, k, v)
                end
              end
            end,
          })

          highlights.normal = {
            Search = { fg = "#c8d3f5", bg = "#3e68d7" },
            IncSearch = { fg = "#1b1d2b", bg = "#ff966c" },
            MsgArea = { fg = "#828bb8" },
            NormalFloat = { fg = "#c8d3f5", bg = "#1e2030" },
          }

          highlights.lsp = {}

          highlights.cmp = {
            CmpItemAbbrMatch = { fg = "#569CD6" },
            CmpItemAbbrMatchFuzzy = { fg = "#3e68d7" },
            CmpItemMenu = { fg = "#cba6f7", bg = "NONE", italic = true },
          }

          highlights.flash = {
            FlashLabel = { fg = "#c8d3f5", bg = "#ff007c" },
          }

          highlights.treesitter = {
            TreesitterContextLineNumber = { link = "Boolean" },
          }

          highlights.telescope = {
            TelescopeMatching = { link = "@lsp.type.type" },
          }

          return highlights
        end,
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
    opts = { scope = { show_start = false, show_end = true } },
  },
  {
    "rcarriga/nvim-notify",
    opts = {
      stages = "static",
      fps = 5,
      timeout = 1200,
    },
  },
}
