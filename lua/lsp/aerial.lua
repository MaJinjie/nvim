---@type LazySpec
return {
  "stevearc/aerial.nvim",
  opts = function(_, opts)
    opts.filter_kind = {
      "Class",
      "Constructor",
      "Enum",
      "Function",
      "Interface",
      "Method",
      "Module",
      "Namespace",
      "Object",
      "Operator",
      "Package",
      "Property",
      "Struct",
    }
    opts.keymaps = nil

    opts.float = { relative = "editor" }

    opts.nav = {
      max_height = 0.9,
      min_height = { 20, 0.5 },
      max_width = 0.5,
      min_width = { 0.2, 0.6 },
      autojump = false,
      preview = true,
    }
  end,
}
