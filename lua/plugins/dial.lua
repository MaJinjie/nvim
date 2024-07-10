---@type LazyPluginSpec
return {
  "monaqa/dial.nvim",
  specs = {
    "AstroNvim/astrocore",
    opts = function()
      local map = require("utils").keymap.set

      map {
        n = {
          ["<C-a>"] = {
            function() return require("dial.map").manipulate("increment", "normal") end,
            desc = "Increment",
          },
          ["<C-x>"] = {
            function() return require("dial.map").manipulate("decrement", "normal") end,
            desc = "Decrement",
          },
          ["g<C-a>"] = {
            function() return require("dial.map").manipulate("increment", "gnormal") end,
            desc = "Increment",
          },
          ["g<C-x>"] = {
            function() return require("dial.map").manipulate("decrement", "gnormal") end,
            desc = "Decrement",
          },
        },
        v = {
          ["<C-a>"] = {
            function() return require("dial.map").manipulate("increment", "visual") end,
            desc = "Increment",
          },
          ["<C-x>"] = {
            function() return require("dial.map").manipulate("decrement", "visual") end,
            desc = "Decrement",
          },
          ["g<C-a>"] = {
            function() return require("dial.map").manipulate("increment", "gvisual") end,
            desc = "Increment",
          },
          ["g<C-x>"] = {
            function() return require("dial.map").manipulate("decrement", "gvisual") end,
            desc = "Decrement",
          },
        },
      }
    end,
  },
  config = function()
    local augend = require "dial.augend"

    -- stylua: ignore
    require("dial.config").augends:register_group {
      default = {
        augend.integer.alias.decimal_int,
        augend.integer.alias.hex,
        augend.constant.alias.bool,
        augend.constant.new {
          elements = { "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", },
          cyclic = true,
        },
        augend.constant.new {
          elements = { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", },
          cyclic = true,
        },
        augend.semver.alias.semver,
        augend.date.alias["%Y/%m/%d"],
        augend.date.new {
          pattern = "%B", -- titlecased month names
          default_kind = "day",
        },
        augend.constant.new {
          elements = { "and", "or" },
          word = true, -- if false, "sand" is incremented into "sor", "doctor" into "doctand", etc.
          cyclic = true, -- "or" is incremented into "and".
        },
        augend.constant.new {
          elements = { "&&", "||" },
          word = false,
          cyclic = true,
        },
        augend.constant.new {
          elements = { "january", "february", "march", "april", "may", "june", "july", "august", "september", "october", "november", "december", },
          word = true,
          cyclic = true,
        },
        augend.constant.new {
          elements = { "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday", },
          word = true,
          cyclic = true,
        },
        augend.constant.new {
          elements = { "monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday", },
          word = true,
          cyclic = true,
        },
        augend.hexcolor.new {
          case = "lower",
        },
        augend.case.new {
          types = { "camelCase", "PascalCase", "snake_case" },
        },
      },
    }
  end,
}
