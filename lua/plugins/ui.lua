return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      return vim.tbl_deep_extend("force", opts, require("plugins.config.lualine"))
    end,
  },
  {
    "petertriho/nvim-scrollbar",
    event = "LazyFile",
    opts = {
      excluded_buftypes = {},
      excluded_filetypes = { "snacks_picker_list", "snacks_picker_input", "snacks_notif", "snacks_input", "noice" },
    },
  },
  {
    "norcalli/nvim-colorizer.lua",
    event = "LazyFile",
    opts = function()
      local colorizer = require("colorizer")
      Snacks.toggle({
        name = "Colorizer",
        get = colorizer.is_buffer_attached,
        set = function(state)
          if state then
            colorizer.attach_to_buffer()
          else
            colorizer.detach_from_buffer()
          end
        end,
      }):map("<leader>uH")
    end,
  },
  {
    "xiyaowong/transparent.nvim",
    enabled = false,
    opts = {
      extra_groups = { "NormalFloat", "TreesitterContext", "LspInlayHint", "BlinkCmpMenu" },
    },
  },
}
