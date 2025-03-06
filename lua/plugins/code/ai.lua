local M = {
  textobjects = {},
}

-- taken from MiniExtra.gen_ai_spec.buffer
function M.textobjects.buffer(ai_type)
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

-- register all text objects with which-key
function M.register_whichkey()
  local objects = {
    { " ", desc = "whitespace" },
    { '"', desc = '" string' },
    { "'", desc = "' string" },
    { "(", desc = "() block" },
    { ")", desc = "() block with ws" },
    { "<", desc = "<> block" },
    { ">", desc = "<> block with ws" },
    { "?", desc = "user prompt" },
    { "U", desc = "use/call without dot" },
    { "[", desc = "[] block" },
    { "]", desc = "[] block with ws" },
    { "_", desc = "underscore" },
    { "`", desc = "` string" },
    { "a", desc = "argument" },
    { "b", desc = ")]} block" },
    { "c", desc = "class" },
    { "d", desc = "digit(s)" },
    { "e", desc = "CamelCase / snake_case" },
    { "f", desc = "function" },
    { "G", desc = "entire file" },
    { "i", desc = "indent" },
    { "o", desc = "block, conditional, loop" },
    { "q", desc = "quote `\"'" },
    { "t", desc = "tag" },
    { "u", desc = "use/call" },
    { "{", desc = "{} block" },
    { "}", desc = "{} with ws" },

    { ";", desc = "next textobject" },
    { ",", desc = "prev textobject" },
  }

  ---@type wk.Spec[]
  local operators_ret = { mode = { "o", "x" } }
  ---@type table<string, string>
  local operators = {
    -- Main textobject prefixes
    around = "a",
    inside = "i",

    -- Next/last textobjects
    around_next = "a;",
    inside_next = "i;",
    around_last = "a,",
    inside_last = "i,",
  }
  for name, prefix in pairs(operators) do
    name = name:gsub("^around_", ""):gsub("^inside_", "")
    operators_ret[#operators_ret + 1] = { prefix, group = name }
    for _, obj in ipairs(objects) do
      local desc = obj.desc
      if prefix:sub(1, 1) == "i" then
        desc = desc:gsub(" with ws", "")
      end
      operators_ret[#operators_ret + 1] = { prefix .. obj[1], desc = obj.desc }
    end
  end

  ---@type wk.Spec[]
  local moves_ret = { mode = { "n", "o", "x" } }
  local moves = {
    -- Move cursor to corresponding edge of `a` textobject
    goto_left = "g,",
    goto_right = "g;",
  }

  for name, prefix in pairs(moves) do
    name = name:gsub("^goto_", "")
    moves_ret[#moves_ret + 1] = { prefix, group = name }
    for _, obj in ipairs(objects) do
      moves_ret[#moves_ret + 1] = { prefix .. obj[1], desc = obj.desc:gsub(" with ws", "") }
    end
  end

  require("which-key").add(operators_ret, { notify = false })
  require("which-key").add(moves_ret, { notify = false })
end

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
        -- TODO: read mini.ai
        e = { -- Word with case
          { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
          "^().*()$",
        },
        G = M.textobjects.buffer, -- buffer
        u = ai.gen_spec.function_call(), -- u for "Usage"
        U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
      },
      mappings = {
        -- Main textobject prefixes
        around = "a",
        inside = "i",

        -- Next/last textobjects
        around_next = "a;",
        inside_next = "i;",
        around_last = "a,",
        inside_last = "i,",

        -- Move cursor to corresponding edge of `a` textobject
        goto_left = "g,",
        goto_right = "g;",
      },
    }
  end,
  config = function(_, opts)
    require("mini.ai").setup(opts)
    User.util.on_lazyload("which-key.nvim", function()
      vim.schedule(M.register_whichkey)
    end)
  end,
}
