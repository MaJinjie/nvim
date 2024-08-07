---@type LazySpec
return {
  "mg979/vim-visual-multi",
  event = { "User AstroFile" },
  specs = {
    "AstroNvim/astrocore",
    opts = {
      options = {
        g = {
          VM_theme = "sand",
          VM_silent_exit = 1,
          VM_show_warnings = 0,
          VM_mouse_mappings = 1,
          VM_maps = {
            ["Select h"] = "<S-A-h>",
            ["Select l"] = "<S-A-l>",
            ["Add Cursor Down"] = "<S-A-j>",
            ["Add Cursor Up"] = "<S-A-k>",
            -- ["Select Cursor Down"] = "<S-A-j>",
            -- ["Select Cursor Up"] = "<S-A-k>",
            ["Find Under"] = "<C-n>",
          },
        },
      },
      autocmds = {
        visual_multi_exit = {
          {
            event = "User",
            pattern = "visual_multi_exit",
            desc = "Avoid spurious 'hit-enter-prompt' when exiting vim-visual-multi",
            callback = function()
              local old_cmdheight = vim.o.cmdheight
              vim.o.cmdheight = 1
              vim.schedule(function() vim.o.cmdheight = old_cmdheight end)
            end,
          },
        },
      },
    },
  },
}
