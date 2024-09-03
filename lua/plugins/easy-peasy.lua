return {
  {
    "mg979/vim-visual-multi",
    init = function()
      vim.g.VM_theme = "sand"
      vim.g.VM_silent_exit = 1
      vim.g.VM_show_warnings = 0
      vim.g.VM_mouse_mappings = 1
      vim.g.VM_maps = {
        ["Select h"] = "<S-A-h>",
        ["Select l"] = "<S-A-l>",
        ["Select Cursor Down"] = "<S-A-j>",
        ["Select Cursor Up"] = "<S-A-k>",
        ["Add Cursor Down"] = "<S-A-n>",
        ["Add Cursor Up"] = "<S-A-p>",
        ["Find Under"] = "<C-n>",
      }
    end,
    event = "LazyFile",
  },
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "LazyFile",
    opts = {
      keymaps = {
        normal = "gsy",
        normal_cur = "gsyy",
        normal_line = "gsY",
        normal_cur_line = "gsYY",
        visual = "gs",
        visual_line = "gS",
        delete = "gsd",
        change = "gsc",
        change_line = "gsC",
      },
    },
  },
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    opts = { default_mappings = false, mappings = { i = { j = { k = "<Esc>" } } } },
  },
  {
    "folke/twilight.nvim",
    cmd = "Twilight",
    keys = { { "<leader>ut", "<cmd> Twilight <cr>", desc = "Toggle Twilight" } },
  },
  {
    "Wansmer/treesj",
    cmd = "TSJToggle",
    keys = { { "<leader>j", "<cmd> TSJToggle <cr>", desc = "Toggle Treesitter Join" } },
    opts = { use_default_keymaps = false },
  },
  { "keaising/im-select.nvim", event = "InsertEnter", opts = {} },
  {
    "folke/persistence.nvim",
    -- stylua: ignore
    keys = {
      { "<leader>qs", function() require("persistence").select() end, desc = "Select Session" },
      { "<leader>qS", function() require("persistence").save() end, desc = "Save Session" },
      { "<leader>ql", function() require("persistence").load() end, desc = "Restore Session" },
      { "<leader>qL", function() require("persistence").load({last = true}) end, desc = "Restore Last Session" },
    },
  },
  {
    "echasnovski/mini.pairs",
    init = function()
      local map_bs = function(lhs, rhs)
        vim.keymap.set({ "i", "c" }, lhs, rhs, { expr = true, replace_keycodes = false })
      end

      map_bs("<C-h>", "v:lua.MiniPairs.bs()")
      map_bs("<C-w>", 'v:lua.MiniPairs.bs("\23")')
      map_bs("<C-u>", 'v:lua.MiniPairs.bs("\21")')
    end,
    opts = { mappings = { ["'"] = false } },
  },
}
