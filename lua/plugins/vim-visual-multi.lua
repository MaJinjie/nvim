return {
  "mg979/vim-visual-multi",
  event = "LazyFile",
  init = function()
    vim.g.VM_theme = "sand"
    vim.g.VM_silent_exit = 1
    vim.g.VM_show_warnings = 0
    vim.g.VM_mouse_mappings = 1

    vim.g.VM_maps = {
      -- ["Select h"] = "<S-A-h>",
      -- ["Select l"] = "<S-A-l>",
      -- ["Select j"] = "<S-A-j>",
      -- ["Select k"] = "<S-A-k>",
      -- ["Add Cursor Down"] = "<A-j>",
      -- ["Add Cursor Up"] = "<A-k>",
      -- ["Single Select l"] = "<A-l>",
      -- ["Single Select h"] = "<A-h>",

      ["Undo"] = "u",
      ["Redo"] = "<C-r>",
    }
  end,
}
