---@type LazySpec
return {
  "stevearc/aerial.nvim",
  opts = function(_, opts)
    local iterator = require "uts.iterator"
    local user_opts = iterator(opts)

    user_opts {
      filter_kind = {
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
      },
      keymaps = {},

      float = { relative = "editor" },

      nav = {
        max_height = 0.9,
        min_height = { 20, 0.5 },
        max_width = 0.5,
        min_width = { 0.2, 0.6 },
        autojump = false,
        preview = true,
      },
    }
  end,
  dependencies = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local iterator = require "uts.iterator"
        local mappings = iterator(opts.mappings, false)

        mappings "n" {
          ["<Leader>ls"] = { "<Cmd> AerialToggle <Cr>", desc = "Symbols outline" },
          ["<Leader>lS"] = { "<Cmd> Telescope aerial <Cr>", desc = "Symbols nav outline" },
        }
      end,
    },
  },
}
