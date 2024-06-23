---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
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
    signs = {
      BqfSign = { text = " " .. require("astroui").get_icon "Selected", texthl = "BqfSign" },
    },
    on_keys = {
      auto_hlsearch = false, -- hlslens
    },
    -- vim options can be configured here
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
        neovide_scale_factor = 0.87,
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

        -- neo-tree
        ["<Leader>E"] = {
          "<Cmd> Neotree toggle reveal_force_cwd dir=%:p:h <Cr>",
          desc = "toggle Explorer reveal_force_cwd",
        },
        -- treesitter
        ["[e"] = { function() require("treesitter-context").go_to_context(vim.v.count1) end, desc = "Backward context" },
        -- telescope
        ["<Leader>fg"] = { function() require("telescope.builtin").git_files() end, desc = "Find git files" },
        ["<Leader>fo"] = { function() require("telescope").extensions.frecency.frecency() end, desc = "Find history" },
        ["<Leader>fe"] = {
          function() require("telescope").extensions.file_browser.file_browser { path = vim.fn.expand "%:p:h" } end,
          desc = "Find currentDir files",
        },
        ['<Leader>f"'] = { function() require("telescope.builtin").registers() end, desc = "Find Registers" },
        ["<Leader>fH"] = { "<Cmd> Telescope helpgrep <Cr>", desc = "Grep help" },
        ["<Leader>fL"] = { "<Cmd> Telescope lazy <Cr>", desc = "Find lazyplugins" },
        ["<Leader>fw"] = {
          function() require("telescope").extensions.egrepify.egrepify { cwd = vim.fn.expand "%:p:h" } end,
          desc = "Grep word in current file directory",
        },
        ["<Leader>fW"] = {
          function() require("telescope").extensions.egrepify.egrepify { cwd = vim.uv.cwd() } end,
          desc = "Grep word in cwd",
        },
        ["<Leader>fu"] = { "<Cmd> Telescope undo <Cr>", desc = "Find Undotree" },
        -- treej
        ["\\j"] = { "<Cmd> TSJToggle <Cr>", desc = "Toggle Treesitter Join" },
        -- zen-mode
        ["<Leader>uz"] = { "<Cmd> ZenMode <Cr>", desc = "Toggle ZenMode" },
        ["<Leader>uT"] = { "<Cmd> Twilight <Cr>", desc = "Toggle Twilight" },
        -- neogit
        ["<Leader>gn"] = { "<Cmd>Neogit<CR>", desc = "Open Neogit Tab Page" },
        -- aerial
        ["<Leader>fy"] = { "<Cmd> AerialToggle <Cr>", desc = "Symbols outline" },
        ["<Leader>fY"] = { "<Cmd> AerialNavToggle <Cr>", desc = "Symbols nav outline" },
        -- spectre
        ["<Leader>fr"] = {
          function() require("spectre").open_file_search { select_word = true } end,
          desc = "Spectre (current file)",
        },
        ["<Leader>fR"] = {
          function() require("spectre").open { select_word = true } end,
          desc = "Spectre",
        },
        -- overseer
        ["<Leader>T"] = { desc = require("astroui").get_icon("Overseer", 1, true) .. "Overseer" },
      },
      i = {
        ["<C-Cr>"] = { "<Esc>o", noremap = true, silent = true },
      },
    },
  },
  autocmds = {
    -- crate
    CmpSourceCargo = {
      {
        event = "BufRead",
        desc = "Load crates.nvim into Cargo buffers",
        pattern = "Cargo.toml",
        callback = function()
          require "crates"
          require("cmp").setup.buffer {
            sources = {
              { name = "nvim_lsp", priority = 1000 },
              { name = "crates", priority = 750 },
              { name = "buffer", priority = 500 },
              { name = "path", priority = 250 },
            },
          }
        end,
      },
    },
    -- leetcode
    leetcode_autostart = {
      {
        event = "VimEnter",
        desc = "Start leetcode.nvim on startup",
        nested = true,
        callback = function()
          if vim.fn.argc() ~= 1 then return end -- return if more than one argument given
          local arg = vim.tbl_get(require("astrocore").plugin_opts "leetcode.nvim", "arg") or "leetcode.nvim"
          if vim.fn.argv()[1] ~= arg then return end -- return if argument doesn't match trigger
          local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
          if #lines > 1 or (#lines == 1 and lines[1]:len() > 0) then return end -- return if buffer is non-empty
          require("leetcode").start(true)
        end,
      },
      {
        event = "BufRead",
        pattern = "*/.local/nvim/leetcode/*",
        callback = function()
          require("cmp").setup.buffer {
            sources = {
              { name = "buffer" },
            },
          }
        end,
      },
    },
  },
}
