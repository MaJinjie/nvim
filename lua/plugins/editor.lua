local M = {}

return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
      current_line_blame_opts = { delay = 500 },
      on_attach = function(buffer)
        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        -- stylua: ignore start
        map("n", "]c", function() if vim.wo.diff then vim.cmd.normal({ "]c", bang = true }) else require('gitsigns').nav_hunk("next") end end)
        map("n", "[c", function() if vim.wo.diff then vim.cmd.normal({ "]c", bang = true }) else require('gitsigns').nav_hunk("prev") end end)
        map({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>")
        map({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<CR>")
        map("n", "<leader>hS", "<cmd>Gitsigns stage_buffer<cr>")
        map("n", "<leader>hR", "<cmd>Gitsigns reset_buffer<cr>")
        map("n", "<leader>hu", "<cmd>Gitsigns undo_stage_hunk<cr>")
        map("n", "<leader>hU", "<cmd>Gitsigns toggle_deleted<cr>")
        map("n", "<leader>hp", "<cmd>Gitsigns preview_hunk_inline<cr>")
        map("n", "<leader>hP", "<cmd>Gitsigns preview_hunk<cr>")
        map("n", "<leader>hb", "<cmd>lua require'gitsigns'.blame_line{full=true}<cr>")
        map("n", "<leader>hB", "<cmd>Gitsigns blame<cr>")
        map("n", "<leader>hd", "<cmd>Gitsigns diffthis<CR>")
        map("n", "<leader>hD", '<cmd>lua require"gitsigns".diffthis("~")<CR>')
        map("n", "<leader>hq", "<cmd>Gitsigns setqflist<cr>")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<cr>")
        -- stylua: ignore end
      end,
    },
  },
  { "nmac427/guess-indent.nvim", event = "BufReadPost", cmd = "GuessIndent", opts = {} },
  {
    "gbprod/yanky.nvim",
    event = "LazyFile",
    cmd = { "YankyRingHistory", "YankyClearHistory" },
    keys = {
      -- stylua: ignore
      { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank Text" },
      { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put Text After Cursor" },
      { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put Text Before Cursor" },
      { "[p", "<Plug>(YankyCycleForward)", desc = "Cycle Forward Through Yank History" },
      { "]p", "<Plug>(YankyCycleBackward)", desc = "Cycle Backward Through Yank History" },
      { "gp", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put Indented After Cursor (Linewise)" },
      { "gP", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put Indented Before Cursor (Linewise)" },
      { "=p", "<Plug>(YankyPutAfterFilter)", desc = "Put After Applying a Filter" },
      { "=P", "<Plug>(YankyPutBeforeFilter)", desc = "Put Before Applying a Filter" },
    },
    opts = { highlight = { timer = 150 } },
  },
  {
    "hedyhli/outline.nvim",
    keys = {
      {
        "<leader>o",
        function()
          local outline = M.outline.get_or_new()

          if outline:is_open() then
            outline:focus_toggle()
          else
            outline:open({ focus_outline = true })
          end
        end,
        desc = "Open|Toggle Focus Outline",
      },
      {
        "<leader>O",
        function()
          local outline = M.outline.get_or_new()
          if outline:is_open() then
            local has_focus = outline:has_focus()
            outline:close()
            if has_focus then
              M.outline.get_or_new(true):open()
            end
          else
            outline:open({ focus_outline = false })
          end
        end,
        desc = "Open|Close Outline",
      },
    },
    cmd = "Outline",
    init = function()
      M.outline = {}
      M.outline.get_or_new = function(is_toggle)
        local preview_opts = require("outline.config").o.preview_window
        if is_toggle then
          preview_opts.auto_preview = not preview_opts.auto_preview
        end

        local outline, Sidebar = require("outline"), require("outline.sidebar")
        local id = ("%s:%s"):format(vim.api.nvim_get_current_tabpage(), preview_opts.auto_preview and 1 or 0)
        if not outline.sidebars[id] then
          outline.sidebars[id] = Sidebar:new(id)
        end
        return outline.sidebars[id]
      end
    end,
    opts = {
      outline_window = {
        width = 40,
        relative_width = false,
      },
      preview_window = {
        auto_preview = false,
        open_hover_on_preview = true,
        winblend = vim.o.winblend,
        live = true,
      },
      outline_items = {
        show_symbol_details = false,
      },
      symbols = {
        filter = LazyVim.config.kind_filter,
        icon_fetcher = function(kind)
          return LazyVim.config.icons.kinds[kind]
        end,
      },
    },
  },
  {
    "mg979/vim-visual-multi",
    event = "LazyFile",
    init = function()
      vim.g.VM_silent_exit = 1
      vim.g.VM_mouse_mappings = 1
      vim.g.VM_theme = "sand"

      vim.g.VM_maps = {
        ["Select h"] = "<S-A-h>",
        ["Select l"] = "<S-A-l>",
        ["Select j"] = "<S-A-j>",
        ["Select k"] = "<S-A-k>",
        ["Add Cursor Down"] = "<A-j>",
        ["Add Cursor Up"] = "<A-k>",
        ["Single Select l"] = "<A-l>",
        ["Single Select h"] = "<A-h>",

        ["Undo"] = "u",
        ["Redo"] = "<C-r>",
      }
      vim.api.nvim_create_autocmd({ "User" }, {
        pattern = "visual_multi_start",
        callback = function()
          ---@diagnostic disable-next-line: missing-parameter
          require("lualine").hide()
        end,
      })
      vim.api.nvim_create_autocmd({ "User" }, {
        pattern = "visual_multi_exit",
        callback = function()
          ---@diagnostic disable-next-line: missing-fields
          require("lualine").hide({ unhide = true })
        end,
      })
    end,
  },
}
