---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@param opts AstroCoreOpts
  opts = function(_, opts)
    local map, del = require("utils").keymap.set, require("utils").keymap.del

    del {
      n = { "\\", "<Leader>n" },
    }

    map {
      n = {
        ["_"] = { "<Cmd> split <Cr>", desc = "Horizontal Split" },
        ["<Esc>"] = { "<Esc><Cmd>nohlsearch<CR>", desc = "esc nohlsearch", noremap = true },

        ["<Leader>n"] = { desc = require("astroui").get_icon("New", 1, true) .. "New" },
        ["<Leader>nt"] = { "<Cmd> tabnew <CR>", desc = "New a tab" },
        ["<Leader>nf"] = {
          function()
            vim.ui.input({ prompt = "Input a FileName" }, function(input)
              if input then vim.cmd.edit(string.format("%s/%s", vim.fn.expand "%:p:h", input)) end
            end)
          end,
        },
        ["<Leader>nF"] = {
          function()
            vim.ui.input({
              prompt = "Input a FileName",
              default = string.format("%s/", vim.fn.expand "%:p:h"),
            }, function(input)
              if input then vim.cmd.edit(input) end
            end)
          end,
        },
      },
      i = {
        ["<C-a>"] = {
          function()
            local lnum, _ = (table.unpack or unpack)(vim.api.nvim_win_get_cursor(0))
            vim.api.nvim_win_set_cursor(0, { lnum, vim.fn.indent(lnum) })
          end,
        },
        ["<C-e>"] = { "<End>", desc = "Jump to Current line end" },
        ["<C-H>"] = "<Left>",
        ["<C-L>"] = "<Right>",
      },
      c = {
        ["<C-H>"] = "<Left>",
        ["<C-L>"] = "<Right>",
      },
    }

    return vim.tbl_deep_extend("force", opts, {
      -- pass to telescope.default.git_worktrees
      git_worktrees = {
        {
          toplevel = vim.env.HOME,
          gitdir = vim.env.HOME .. "/.dotfiles",
        },
      },
      rooter = {
        detector = {
          "lsp",
          { ".git" },
          { "MakeFile", "CMakeLists.txt" },
        },
        autochdir = false,
        scope = "tab",
        notify = true,
      },
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
        update_in_insert = false,
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
        },
      },
      signs = {},
      on_keys = {},
      sessions = {},
      filetypes = {},
    })
  end,
  config = function(_, opts)
    local keymap = require("utils").keymap
    opts.mappings = keymap.merge_mappings(opts.mappings)

    require("astrocore").setup(opts)
    keymap.report_override_mappings { title = "Override Key Mappings" }
  end,
}
