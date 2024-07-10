---@type LazySpec
return {
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "User AstroFile",
    cmd = "TSContextToggle",
    opts = { max_lines = 3, multiline_threshold = 1 },
    specs = {
      "AstroNvim/astrocore",
      opts = function()
        local nmap = require("utils").keymap.set.n

        nmap {
          ["[E"] = {
            function() require("treesitter-context").go_to_context(vim.v.count1) end,
            desc = "Backward context",
          },
          ["<Leader>uE"] = { "<Cmd> TSContextToggle <Cr>", desc = "Toggle context display" },
        }
      end,
    },
  },
  { "lukas-reineke/headlines.nvim", ft = { "markdown", "norg", "org", "rmd" }, opts = {} },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      textobjects = {
        select = {
          keymaps = {
            ["ia"] = { query = "@parameter.inner", desc = "inside argument" },
            ["aa"] = { query = "@parameter.outer", desc = "around argument" },
            ["ic"] = { query = "@call.inner", desc = "inside call" },
            ["ac"] = { query = "@call.outer", desc = "around call" },
            ["iC"] = { query = "@class.inner", desc = "inside class" },
            ["aC"] = { query = "@class.outer", desc = "around class" },
            ["ik"] = { query = "@block.inner", desc = "inside block" },
            ["ak"] = { query = "@block.outer", desc = "around block" },
            ["i?"] = { query = "@conditional.inner", desc = "inside conditional" },
            ["a?"] = { query = "@conditional.outer", desc = "around conditional" },
            ["io"] = { query = "@loop.inner", desc = "inside loop" },
            ["ao"] = { query = "@loop.outer", desc = "around loop" },
            ["af"] = { query = "@function.outer", desc = "around function " },
            ["if"] = { query = "@function.inner", desc = "inside function " },
            ["il"] = { query = "@assignment.lhs", desc = "assignment lhs" },
            ["ir"] = { query = "@assignment.rhs", desc = "assignment rhs" },
          },
        },
        move = {
          goto_next_start = {
            ["]c"] = { query = "@class.outer", desc = "Next class start" },
            ["]k"] = { query = "@block.outer", desc = "Next block start" },
            ["]f"] = { query = "@function.outer", desc = "Next function start" },
            ["]a"] = { query = "@parameter.inner", desc = "Next argument start" },
          },
          goto_next_end = {
            ["]C"] = { query = "@class.outer", desc = "Next class end" },
            ["]K"] = { query = "@block.outer", desc = "Next block end" },
            ["]F"] = { query = "@function.outer", desc = "Next function end" },
            ["]A"] = { query = "@parameter.inner", desc = "Next argument end" },
          },
          goto_previous_start = {
            ["[c"] = { query = "@class.outer", desc = "Previous class start" },
            ["[k"] = { query = "@block.outer", desc = "Previous block start" },
            ["[f"] = { query = "@function.outer", desc = "Previous function start" },
            ["[a"] = { query = "@parameter.inner", desc = "Previous argument start" },
          },
          goto_previous_end = {
            ["[C"] = { query = "@class.outer", desc = "Previous class end" },
            ["[K"] = { query = "@block.outer", desc = "Previous block end" },
            ["[F"] = { query = "@function.outer", desc = "Previous function end" },
            ["[A"] = { query = "@parameter.inner", desc = "Previous argument end" },
          },
        },
      },
    },
  },
  {
    "chrisgrieser/nvim-various-textobjs",
    event = "User AstroFile",
    opts = { useDefaultKeymaps = false },
    specs = {
      "AstroNvim/astrocore",
      opts = function()
        local map = require("utils").keymap.set

        map[{ "o", "x" }] = {
          ["ii"] = {
            '<cmd>lua require("various-textobjs").indentation("inner", "inner", "noBlanks")<CR>',
          },
          ["ai"] = {
            '<cmd>lua require("various-textobjs").indentation("inner", "inner")<CR>',
          },
          ["_"] = {
            '<cmd>lua require("various-textobjs").restOfIndentation()<CR>',
          },
          ["i_"] = {
            '<cmd>lua require("various-textobjs").lineCharacterwise("inner")<CR>',
          },
          ["a_"] = {
            '<cmd>lua require("various-textobjs").lineCharacterwise("outer")<CR>',
          },
          ["gG"] = {
            '<cmd>lua require("various-textobjs").entireBuffer()<CR>',
          },
        }
      end,
    },
  },
}
