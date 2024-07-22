---@type LazySpec
return {
  "MaJinjie/null.nvim",
  cond = vim.g.neovide or false,
  specs = {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      options = {
        g = {
          neovide_scale_factor = 0.85,
          neovide_padding_top = 5,
          neovide_padding_bottom = 0,
          neovide_padding_right = 0,
          neovide_padding_left = 0,
          neovide_transparency = 0.8,
          neovide_window_blurred = true,
          neovide_hide_mouse_when_typing = true,
          -- neovide_flatten_floating_zindex = "20",
          -- neovide_floating_shadow = false,
          neovide_remember_window_size = true,
        },
      },
      autocmds = {
        -- 退出插入模式时，取消切换输入法
        Ime_input = {
          {
            event = { "InsertEnter", "InsertLeave" },
            pattern = "*",
            callback = function(args)
              if args.event:match "Enter$" then
                vim.g.neovide_input_ime = true
              else
                vim.g.neovide_input_ime = false
              end
            end,
          },
          {
            event = { "CmdlineEnter", "CmdlineLeave" },
            pattern = "*",
            callback = function(args)
              if args.event:match "Enter$" then
                vim.g.neovide_input_ime = true
              else
                vim.g.neovide_input_ime = false
              end
            end,
          },
        },
      },
    },
  },
}
