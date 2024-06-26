---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 500, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics_mode = 3, -- diagnostic mode on start (0 = off, 1 = no signs/virtual text, 2 = no virtual text, 3 = on)
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        timeoutlen = 300,
        scrolloff = 8,
        sidescrolloff = 8,
        swapfile = false,
        guifont = "JetBrainsMono Nerd Font,Hack Nerd Font:h13",
        tabstop = 4,
        shiftwidth = 4,
        softtabstop = -1,
      },
      g = { -- vim.g.<key>
        transparency = 0.9,
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        ["zh"] = "zH",
        ["zl"] = "zL",
        ["z;"] = { "<Cmd>e #<CR>", desc = "Previous buffer" },
        ["<Esc>"] = { "<Esc><Cmd>nohlsearch<CR>", desc = "esc nohlsearch", noremap = true },
        ["<Leader>W"] = { "<Cmd>w<CR>", desc = "Save all" },
      },
      t = {
        ["<Esc>"] = { "<Esc>", nowait = false },
        ["<Esc><Esc>"] = { "<c-\\><c-n>", desc = "Enter Normal Mode" },
      },
    },
  },
}
