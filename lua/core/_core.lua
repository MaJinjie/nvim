---@type LazySpec
return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      features = {
        large_buf = { size = 1024 * 256, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
        autopairs = true, -- enable autopairs at start
        cmp = true, -- enable completion at start
        diagnostics_mode = 3, -- diagnostic mode on start (0 = off, 1 = no signs/virtual text, 2 = no virtual text, 3 = on)
        highlighturl = true, -- highlight URLs at start
        notifications = true, -- enable notifications at start
      },
      diagnostics = {
        virtual_text = true,
        underline = true,
      },
      options = {
        opt = {
          timeoutlen = 300,
          scrolloff = 8,
          sidescrolloff = 8,
          swapfile = false,
          guifont = "JetBrainsMono Nerd Font,Hack Nerd Font:h13",
          softtabstop = -1,
        },
        g = {
          transparency = 0.8,

          -- neovide
          neovide_scale_factor = 0.85,
          neovide_padding_top = 5,
          neovide_padding_bottom = 0,
          neovide_padding_right = 0,
          neovide_padding_left = 0,
          neovide_transparency = 0.8,
          neovide_window_blurred = true,
          neovide_hide_mouse_when_typing = true,
        },
      },
      mappings = {
        n = {
          ["\\"] = false, -- 将\\作为一个小前缀键

          -- normal
          ["<Esc>"] = { "<Esc><Cmd>nohlsearch<CR>", desc = "esc nohlsearch", noremap = true },
          ["\\|"] = { "<Cmd> split <Cr>", desc = "Horizontal Split" },
        },
        i = {
          ["<C-Cr>"] = { "<Esc>o", noremap = true, silent = true },
        },
      },
      commands = {},
      autocmds = {},
      signs = {},
      rooter = {},
      on_keys = {},
      sessions = {},
      filetypes = {},
    },
  },
}
