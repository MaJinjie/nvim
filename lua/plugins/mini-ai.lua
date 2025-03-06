local M = {}

-- taken from MiniExtra.gen_ai_spec.buffer
function M.buffer(ai_type)
  local start_line, end_line = 1, vim.fn.line("$")
  if ai_type == "i" then
    -- Skip first and last blank lines for `i` textobject
    local first_nonblank, last_nonblank = vim.fn.nextnonblank(start_line), vim.fn.prevnonblank(end_line)
    -- Do nothing for buffer with all blanks
    if first_nonblank == 0 or last_nonblank == 0 then
      return { from = { line = 1, col = 1 } }
    end
    start_line, end_line = first_nonblank, last_nonblank
  end

  local to_col = math.max(vim.fn.getline(end_line):len(), 1)
  return { from = { line = start_line, col = 1 }, to = { line = end_line, col = to_col } }
end

M.text_objects = {
  ["("] = { desc = "() block" },
  ["["] = { desc = "[] block" },
  ["<"] = { desc = "<> block" },
  ["{"] = { desc = "{} block" },

  [")"] = { desc = "() block" },
  ["]"] = { desc = "[] block" },
  [">"] = { desc = "<> block" },
  ["}"] = { desc = "{} block" },
  ["b"] = { desc = ")]} block" },

  ['"'] = { desc = '" string' },
  ["'"] = { desc = "' string" },
  ["`"] = { desc = "` string" },
  ["q"] = { desc = "quote `\"'" },

  ["?"] = { desc = "user prompt" },

  ["a"] = { desc = "argument" },

  ["o"] = { desc = "block, conditional, loop" },
  ["u"] = { desc = "use/call" },
  ["U"] = { desc = "use/call without dot" },
  ["t"] = { desc = "tag" },
  ["c"] = { desc = "class" },
  ["f"] = { desc = "function" },
  ["d"] = { desc = "digit(s)" },
  ["e"] = { desc = "CamelCase / snake_case" },
  ["G"] = { desc = "entire file" },

  ["_"] = { desc = "current line" },
  [" "] = { desc = "whitespace" },
}

User.keymap.add_text_objects(M.text_objects)

-- Better text-objects
return {
  "echasnovski/mini.ai",
  event = "LazyFile",
  opts = function()
    local ai = require("mini.ai")

    return {
      n_lines = 500,
      custom_textobjects = {
        o = ai.gen_spec.treesitter({ -- code block
          a = { "@block.outer", "@conditional.outer", "@loop.outer" },
          i = { "@block.inner", "@conditional.inner", "@loop.inner" },
        }),
        f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function
        c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- class
        t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
        d = { "%f[%d]%d+" }, -- digits
        g = M.buffer, -- buffer
        u = ai.gen_spec.function_call(), -- u for "Usage"
        U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name

        -- examples: aaa_bb_cc  aa-bbbcc-cc AcccBccc
        e = {
          { "%f[%u]%u[%l%d]+", "%f[%w]%w+[-_%.]+", "%f[%W][-_%.]+%w+" },
          "^%p*().-()%p*$",
        },
        ["_"] = { "^[^\n\r]*", "^%s*().-()%s*$" },
      },
      mappings = {
        -- Main textobject prefixes
        around = "a",
        inside = "i",

        -- Next/last textobjects
        around_next = "an",
        inside_next = "in",
        around_last = "al",
        inside_last = "il",

        -- Move cursor to corresponding edge of `a` textobject
        goto_left = "g[",
        goto_right = "g]",
      },
    }
  end,
  config = function(_, opts)
    require("mini.ai").setup(opts)
    User.util.on_lazyload("which-key.nvim", function()
      User.keymap.add_which_key({
        mode = { "n" },
        operators = { ["g["] = { group = "left" }, ["g]"] = { group = "right" } },
        motions = M.text_objects,
      })
      User.keymap.add_which_key({
        mode = { "o", "v" },
        operators = { [""] = {}, n = { group = "next" }, l = { group = "last" } },
        objects = M.text_objects,
      })
    end)
  end,
}
