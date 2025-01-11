return {
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    opts = function()
      ---@diagnostic disable-next-line: missing-fields
      require("gruvbox").setup({
        palette_overrides = {},
        overrides = {},
      })
      vim.cmd(":colorscheme gruvbox")
    end,
  },
  {
    "rebelot/heirline.nvim",
    priority = 1000,
    opts = function()
      require("util.heirline").setup()
    end,
  },
  --- usage:
  ---   mappings:
  ---     [c          prev hunk
  ---     ]c          next hunk
  ---     <leader>hs  stage hunk
  ---     <leader>hS  stage buffer
  ---     <leader>hu  undo stage hunk
  ---     <leader>hU  toggle deleted
  ---     <leader>hr  reset hunk
  ---     <leader>hR  reset buffer
  ---     <leader>hp  preview hunk inline
  ---     <leader>hP  preview hunk
  ---     <leader>hb  blame line full
  ---     <leader>hB  blame buffer
  ---     <leader>hd  diff this
  ---     <leader>hD  diff ~
  ---     <leader>hq  quickfix preview hunk
  ---
  ---     ih          select hunk
  {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    opts = {
      current_line_blame = true,
      current_line_blame_opts = { delay = 500 },
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      signs_staged = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
      },
      on_attach = function(bufnr)
        local function map(mode, lhs, rhs, opts)
          opts = vim.tbl_extend("force", { buffer = bufnr, noremap = true, silent = true }, opts or {})
          vim.keymap.set(mode, lhs, rhs, opts)
        end

        map("n", "]c", "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", { expr = true })
        map("n", "[c", "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", { expr = true })
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
      end,
    },
  },
  --- usage:
  ---   mappings:
  ---     <esc> to cancel and close the popup
  ---     <bs> go up one level
  ---     <c-d> scroll down
  ---     <c-u> scroll up
  {
    "folje/which-key.nvim",
    event = "VeryLazy",
    opts_extend = { "spec" },
    opts = {
      preset = "helix",
      defaults = {},
      spec = {
        {
          mode = { "n", "v" },
          { "<leader><tab>", group = "tabs" },
          { "<leader>c", group = "code" },
          { "<leader>d", group = "debug" },
          { "<leader>f", group = "find" },
          { "<leader>g", group = "git" },
          { "<leader>s", group = "search" },
          { "<leader>u", group = "ui", icon = { icon = "󰙵 ", color = "cyan" } },
          { "<leader>h", group = "gitsigns" },
          { "[", group = "prev" },
          { "]", group = "next" },
          { "g", group = "goto" },
          { "ys", group = "surround add" },
          { "yS", group = "surround line add" },
          { "ds", group = "surround del" },
          { "cs", group = "surround cha" },
          { "cS", group = "surround line cha" },
          { "z", group = "fold/toggle" },
          {
            "<leader>b",
            group = "buffer",
            expand = function()
              return require("which-key.extras").expand.buf()
            end,
          },
          {
            "<leader>w",
            group = "Windows",
            proxy = "<c-w>",
            expand = function()
              return require("which-key.extras").expand.win()
            end,
          },
          -- better descriptions
          { "gx", desc = "Open with system app" },
          { "s", desc = "jump in the current window" },
          { "S", desc = "jump in the other window" },
          { "gs", desc = "remote action" },
          { "ga", desc = "select treesitter node" },
          { "gA", desc = "select treesitter node (V)" },
        },
      },
    },
    keys = {
      {
        "<C-w>,",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Keymaps (which-key)",
      },
      {
        "<C-w><enter>",
        function()
          require("which-key").show({ keys = "<c-w>", loop = true })
        end,
        desc = "Window Hydra Mode (which-key)",
      },
    },
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = false,
        command_palette = true,
        long_message_to_split = true,
      },
    },
  },
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    opts = {
      timeout = 1500,
      stages = "static",
      minimum_width = 15,
      max_width = 50,
      max_height = 10,
      render = "default",
      on_open = function(winnr)
        local bufnr = vim.api.nvim_win_get_buf(winnr)
        vim.bo[bufnr].filetype = "markdown"
        vim.wo[winnr].conceallevel = 3
        vim.wo[winnr].concealcursor = ""
      end,
    },
    config = function(_, opts)
      local notify = require("notify")
      notify.setup(opts)
      vim.notify = notify
    end,
  },
  {
    "echasnovski/mini.indentscope",
    event = "VeryLazy",
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "help", "lazy", "mason", "neo-tree", "notify", "toggleterm" },
        callback = function(ev)
          local buf = ev.buf
          if vim.b[buf].miniindentscope_disable == nil then
            vim.b[buf].miniindentscope_disable = true
          end
        end,
      })
    end,
    opts = function()
      vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", { link = "Delimiter" })
      return {}
    end,
  },
  {
    "brenoprata10/nvim-highlight-colors",
    cmd = "HighlightColors",
    keys = {
      {
        "<leader>uc",
        function()
          require("util.keymap").toggle("Highlight", function(state)
            local p = require("nvim-highlight-colors")
            if state then
              p.turnOff()
              return false
            else
              p.turnOn()
              return true
            end
          end)
        end,
        desc = "Toggle highlights",
      },
    },
    opts = {
      ---@type 'background'|'foreground'|'virtual'
      render = "background",
      enabled_named_colors = false,
    },
  },
  {
    "echasnovski/mini.icons",
    lazy = true,
    config = function()
      local mini_icons = require("mini.icons")
      mini_icons.setup()
      mini_icons.mock_nvim_web_devicons()
    end,
  },
  -- ui components
  { "MunifTanjim/nui.nvim", lazy = true },
}
