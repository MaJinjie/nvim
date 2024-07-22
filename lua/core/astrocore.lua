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
        ["<C-b>"] = {
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
        g = { transparency = 0.8 },
      },
      autocmds = {},
      signs = {},
      on_keys = {},
      sessions = {},
      filetypes = {},
      commands = {},
    })
  end,
  config = function(_, opts)
    local keymap = require("utils").keymap
    opts.mappings = keymap.merge_mappings(opts.mappings)

    require("astrocore").setup(opts)
    -- keymap.report_override_mappings { title = "Override Key Mappings" }
  end,
}
