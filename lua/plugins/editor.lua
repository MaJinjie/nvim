local default_file_explorer = "oil"

vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("start_directory", { clear = true }),
  desc = "Start with directory",
  once = true,
  callback = function()
    if package.loaded[default_file_explorer] then
      return
    else
      local stats = vim.uv.fs_stat(vim.fn.argv(0))
      if stats and stats.type == "directory" then
        require(default_file_explorer)
      end
    end
  end,
})

return {
  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    -- stylua: ignore
    keys = {
     	{ "<leader>-", function() require("oil").open(require('util.root')({specs ={"pwd", "cwd"}})) end, desc = "Oil" },
     	{ "<leader>fo", function() require("oil").open(require('util.root')()) end, desc = "Oil (Follow Cwd)" },
     	{ "<leader>fO", function() require("oil").open(require('util.root')({follow = true})) end, desc = "Oil (Follow Buffer)" },
    },
    opts = function()
      local toggle = {}
      return {
        default_file_explorer = default_file_explorer == "oil",
        use_default_keymaps = false,
        delete_to_trash = true,
        ---@module 'oil.actions'
        keymaps = {
          ["<C-v>"] = { "actions.select", opts = { vertical = true } },
          ["<C-s>"] = { "actions.select", opts = { horizontal = true } },
          ["<C-t>"] = { "actions.select", opts = { tab = true } },
          ["<localleader>w"] = "actions.preview",
          ["<C-f>"] = { "actions.preview_scroll_down" },
          ["<C-b>"] = { "actions.preview_scroll_up" },
          ["<localleader>r"] = "actions.refresh",
          ["<localleader>o"] = { "actions.change_sort", mode = "n" },
          ["<localleader>c"] = { "actions.open_cwd", mode = "n" },
          ["q"] = { "actions.close", mode = "n" },

          ["<CR>"] = "actions.select",
          ["-"] = { "actions.parent", mode = "n" },
          ["`"] = { "actions.cd", mode = "n" },
          ["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },

          ["<C-q>"] = { "actions.send_to_qflist", opts = { target = "qflist", action = "r" } },
          ["<localleader>q"] = { "actions.send_to_qflist", opts = { target = "qflist", action = "a" } },

          ["g?"] = { "actions.show_help", mode = "n" },
          ["gx"] = "actions.open_external",

          ["g."] = { "actions.toggle_hidden", mode = "n" },
          ["gt"] = { "actions.toggle_trash", mode = "n" },
          ["gd"] = {
            desc = "Toggle file detail view",
            callback = function()
              toggle.detail = not toggle.detail
              if toggle.detail then
                require("oil").set_columns({ "icon", "permissions", "size", "mtime" })
              else
                require("oil").set_columns({ "icon" })
              end
            end,
          },
        },
        ---@module 'oil'
      } --[[@as oil.SetupOpts]]
    end,
    config = function(_, opts)
      local oil = require("oil")
      oil.setup(opts)

      local augroup = vim.api.nvim_create_augroup("oil", { clear = true })
      vim.api.nvim_create_autocmd("User", {
        pattern = "OilActionsPost",
        group = augroup,
        desc = "Close buffers when files are deleted in Oil",
        callback = function(args)
          if args.data.err then
            return
          end
          for _, action in ipairs(args.data.actions) do
            if action.type == "delete" then
              local _, path = require("oil.util").parse_url(action.url)
              local bufnr = vim.fn.bufnr(path)
              if bufnr ~= -1 then
                require("util.keymap").buf_delete({ buf = bufnr, wipe = true })
              end
            end
          end
        end,
      })
    end,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = "echasnovski/mini.icons",
    cmd = "Neotree",
    -- stylua: ignore start
		keys = {
			{ "<leader>fe", function() require("neo-tree.command").execute({ toggle = true, dir = require('util.root')() }) end, desc = "Neo-Tree (Follow Cwd)" },
			{ "<leader>fE", function() require("neo-tree.command").execute({ toggle = true, dir = require('util.root')({ follow = true }) }) end, desc = "Neo-Tree (Follow Buffer)" },
		},
		deactivate = function() vim.cmd([[Neotree close]]) end,
    -- stylua: ignore end
    opts = {
      close_if_last_window = true,
      sources = { "filesystem", "buffers", "git_status" },
      open_files_do_not_replace_types = { "terminal", "qf", "Outline" },
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = { enabled = true },
        hijack_netrw_behavior = default_file_explorer == "neo-tree" and "open_default" or "disabled",
        use_libuv_file_watcher = true,
      },
      window = {
        mappings = {
          ["<space>"] = "none",
          ["<bs>"] = "none",
          ["s"] = "none",
          ["S"] = "none",
          ["t"] = "none",
          ["T"] = "none",
          ["/"] = "none",
          ["w"] = "none",
          ["C"] = "none",
          ["D"] = "none",

          ["b"] = "navigate_up",
          ["l"] = "open",
          ["h"] = "close_node",

          ["f"] = "fuzzy_finder",
          ["F"] = "fuzzy_finder_directory",

          ["<localleader>s"] = "open_split",
          ["<localleader>v"] = "open_vsplit",
          ["<localleader>t"] = "open_tab_drop",
          ["<cr>"] = function(state)
            state.commands.open(state)
            require("neo-tree.command").execute({ action = "close" })
          end,

          -- a A
          -- d
          -- r
          -- y Y
          -- x
          -- c
          -- p
          -- m
          -- i
          -- <bs>
          -- < >
          -- .
          -- H
          -- o
          -- <C-x>
          ["r"] = "rename_basename",
          ["R"] = "rename",

          ["<localleader>r"] = "refresh",
          ["g?"] = "show_help",

          ["z"] = "expand_all_nodes",
          ["Z"] = "close_all_nodes",
          ["P"] = { "toggle_preview", config = { use_float = false } },

          ["Y"] = {
            function(state)
              local node = state.tree:get_node()
              local path = node:get_id()
              vim.fn.setreg("+", path, "c")
            end,
            desc = "Copy Path to Clipboard",
          },
        },
        fuzzy_finder_mappings = {
          ["<Tab>"] = "move_cursor_down",
          ["<S-Tab>"] = "move_cursor_up",
          ["<C-n>"] = "move_cursor_down",
          ["<C-p>"] = "move_cursor_up",
          ["<C-j>"] = "move_cursor_down",
          ["<C-k>"] = "move_cursor_up",
        },
      },
      default_component_configs = {
        indent = {
          with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
        git_status = {
          symbols = {
            unstaged = "󰄱",
            staged = "󰱒",
          },
        },
      },
    },
  },
  {
    "gbprod/yanky.nvim",
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
    opts = { highlight = { timer = 200 } },
  },
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    -- stylua: ignore
    keys = {
      { "<leader>sr", function() require("grug-far").open({ transient = true, prefills = { paths = vim.fn.expand("%") } }) end, mode = { "n", "v" }, desc = "Search and Replace (Current File)" },
      { "<leader>sR", function() require("grug-far").open({ transient = true, prefills = { paths = require('util.root')() } }) end, mode = { "n", "v" }, desc = "Search and Replace Root" },
    },
  },
  --- usage:
  ---   mappings:
  ---     s<space><space> jumps to actual end-of-line characters, including empty lines.
  ---     s{char}<space>  jumps to the last character on a line.
  ---     s<enter>        repeats the previous search.
  ---     s{char}<enter>  be used as a multiline substitute for fFtT motions.
  {
    "ggandor/leap.nvim",
      -- stylua: ignore
		keys = {
			{ "s", "<Plug>(leap)", desc = "Leap" },
			{ "S", "<Plug>(leap-from-window)", desc = "Leap from Windows" },
			{ "s", "<Plug>(leap-forward)", mode = { "x" }, desc = "Leap Forward" },
			{ "S", "<Plug>(leap-backward)", mode = { "x" }, desc = "Leap Backward" },
      { "gs", function() require('leap.remote').action() end, mode = {"n", "o"}, desc = "Leap Remote"},
      { "ga", function() require("leap.treesitter").select() end, mode = { "n", "x", "o" }, desc = "Leap Treesitter Node" },
      { "gA", 'V<cmd>lua require("leap.treesitter").select()<cr>', mode = { "n", "x", "o" }, desc = "Leap Treesitter Node (V)" },
		},
    opts = {
      equivalence_classes = { " \t\r\n", "([{", ")]}", "'\"`" },
    },
    config = function(_, opts)
      local leap = require("leap")
      for k, v in pairs(opts) do
        leap.opts[k] = v
      end
    end,
  },
  {
    "ggandor/flit.nvim",
    dependencies = "ggandor/leap.nvim",
    keys = { "f", "F", "t", "T" },
    opts = { labeled_modes = "nxo" },
  },
  --- url: https://github.com/kevinhwang91/nvim-bqf?tab=readme-ov-file#function-table
  --- usage:
  ---   mappings:
  ---
  ---       open:
  ---         o       open the item under the cursor
  ---         O       using drop to open the item under the cursor
  ---         <cr>    open the item, and close quickfix window
  ---
  ---         <c-s>   open the item in horizontal split
  ---         <c-v>   open the item in vertical split
  ---         t       open the item in a new tab
  ---         T       open the item in a new tab, but stay in quickfix window
  ---         <C-t>   open the item in a new tab, and close quickfix window
  ---
  ---       move:
  ---         <c-p>   go to previous file under the cursor in quickfix window
  ---         <c-n>   go to next file under the cursor in quickfix window
  ---         <       cycle to previous quickfix list in quickfix window
  ---         >       cycle to next quickfix list in quickfix window
  ---         '"      go to last selected item in quickfix window
  ---
  ---       marks:
  ---         <Tab>   toggle sign and move cursor up
  ---         <S-Tab> toggle sign and move cursor down
  ---         <Tab>   toggle multiple signs in visual mode
  ---         '<Tab>  toggle signs for same buffers under the cursor
  ---         z<Tab>  clear the signs in current quickfix list
  ---
  ---       preview:
  ---         <C-b> scroll up half-page in preview window
  ---         <C-f> scroll down half-page in preview window
  ---         zo    scroll back to original position in preview window
  ---         zp    toggle preview window between normal and max size
  ---         p     toggle preview for a quickfix list item
  ---         P     toggle auto preview when cursor moves
  ---
  ---       new:
  ---         zn  create new list for signed items
  ---         zN  create new list for non-signed items
  ---
  ---       fzf:
  ---         zf  enter fzf mode for all items
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    dependencies = "junegunn/fzf",
    opts = {
      preview = { win_height = 12 },
      func_map = { open = "o", openc = "<cr>", split = "<C-s>" },
      filter = {},
    },
  },
  --- usage:
  ---   支持 v:count
  ---   default_key:
  ---     ( [ { <
  ---     ) ] } >   :include space
  ---     b         :alias for ) ] }
  ---     " ' `
  ---     q         :alias for " ' `
  ---     ?         :prompt
  ---     t         :tag
  ---     f -> c    :function call
  ---     a         :argument
  ---     <space>   :include digits,punctuation,whitespace
  ---     n         :next variants
  ---     l         :last variants
  ---
  ---     g[ g]     :Move cursor to corresponding edge of `a` textobject
  ---
  {
    "echasnovski/mini.ai",
    event = "UIEnter",
    opts = {},
  },
  {
    "mg979/vim-visual-multi",
    event = "UIEnter",
    init = function()
      vim.g.VM_theme = "sand"
      vim.g.VM_silent_exit = 1
      vim.g.VM_show_warnings = 0
      vim.g.VM_mouse_mappings = 1
      vim.g.VM_leader = "\\"

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
    end,
  },
}

--[[
{
    "mikavilpas/yazi.nvim",
    cmd = "Yazi",
    keys = {
      { "<leader>-", "<cmd>Yazi toggle<cr>", desc = "Toggle yazi" },
      {
        "<leader>fy",
        function()
          local yazi = require("yazi")
          local previous_path = yazi.previous_state and yazi.previous_state.last_hovered
          yazi.yazi(nil, previous_path or require("util.root")())
        end,
        desc = "Toggle yazi (Follow Cwd)",
      },
      {
        "<leader>fy",
        function()
          require("yazi").yazi(nil, require("util.root")({ follow = true }))
        end,
        desc = "Open yazi (Follow Buffer)",
      },
    },
    ---@module 'yazi'
    ---@type YaziConfig
    opts = {
      open_for_directories = default_file_explorer == "yazi",
      yazi_floating_window_winblend = vim.o.winblend,
      keymaps = {
        show_help = "g?",
        open_file_in_vertical_split = "<c-v>",
        open_file_in_horizontal_split = "<c-s>",
        open_file_in_tab = "<c-t>",
        grep_in_directory = "<c-g>",
        replace_in_directory = "<c-r>",
        cycle_open_buffers = "<tab>",
        copy_relative_path_to_selected_files = "<c-y>",
        send_to_quickfix_list = "<c-q>",
        change_working_directory = "<c-x>c",
      },
      yazi_floating_window_border = "single",
      integrations = { grep_in_directory = "fzf-lua", grep_in_selected_files = "fzf-lua" },
    },
  },

--]]
