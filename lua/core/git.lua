---@type LazySpec
return {
  {
    "NeogitOrg/neogit",
    event = "User AstroGitFile",
    opts = function(_, opts)
      local utils = require "astrocore"
      local disable_builtin_notifications = utils.is_available "nvim-notify" or utils.is_available "noice.nvim"
      local ui_utils = require "astroui"
      local fold_signs = { ui_utils.get_icon "FoldClosed", ui_utils.get_icon "FoldOpened" }

      return utils.extend_tbl(opts, {
        disable_builtin_notifications = disable_builtin_notifications,
        telescope_sorter = function()
          if utils.is_available "telescope-fzf-native.nvim" then
            return require("telescope").extensions.fzf.native_fzf_sorter()
          end
        end,
        integrations = {
          telescope = utils.is_available "telescope.nvim",
          diffview = utils.is_available "diffview.nvim",
        },
        signs = { section = fold_signs, item = fold_signs },
      })
    end,
    specs = {
      "nvim-lua/plenary.nvim",
      { "AstroNvim/astroui", opts = function(_, opts) opts.icons.Neogit = "󰰔" end },
      {
        "AstroNvim/astrocore",
        opts = function()
          local nmap = require("utils").keymap.set.n

          nmap { ["<Leader>gn"] = { "<Cmd>Neogit<CR>", desc = "[neogit] Open Neogit Tab Page" } }
        end,
      },
    },
  },
  {
    "sindrets/diffview.nvim",
    event = "User AstroGitFile",
    cmd = { "DiffviewOpen" },
    opts = {
      view = {
        default = {
          layout = "diff2_vertical",
          winbar_info = true,
        },
      },
      hooks = {
        diff_buf_win_enter = function(_) vim.cmd.TSContextDisable() end,
        diff_buf_read = function(bufnr) vim.b[bufnr].view_activated = false end,
      },
    },
    specs = {
      "AstroNvim/astrocore",
      opts = function()
        local nmap = require("utils").keymap.set.n

        nmap { ["<Leader>gD"] = { "<Cmd> DiffviewFileHistory %<CR>", desc = "[diffview] Git diffview" } }
      end,
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
        delay = 400,
        ignore_whitespace = true,
        virt_text_priority = 100,
      },
      current_line_blame_formatter = "<author_time:%R> • <summary> • <author>",
    },
  },
}
