-- Not all LSP servers add brackets when completing a function.
-- To better deal with this, LazyVim adds a custom option to cmp,
-- that you can configure. For example:
--
-- ```lua
-- opts = {
--   auto_brackets = { "python" }
-- }
-- ```
local reset_mapping = function(fallback)
  fallback()
end
local gen_mappings = function(modes, keymaps)
  local cmp = require("cmp")
  local types = require("cmp.types")
  local keys = {}

  keys["<C-e>"] = function(fallback)
    if cmp.visible() then
      cmp.abort()
    else
      fallback()
    end
  end

  keys["<C-Space>"] = function()
    if cmp.visible() then
      cmp.close()
    else
      cmp.complete()
    end
  end

  keys["<C-/>"] = function(fallback)
    if cmp.visible() then
      if cmp.visible_docs() then
        cmp.close_docs()
      else
        cmp.open_docs()
      end
    else
      fallback()
    end
  end

  keys["<Down>"] = cmp.mapping.select_next_item({ behavior = types.cmp.SelectBehavior.Select })
  keys["<Up>"] = cmp.mapping.select_prev_item({ behavior = types.cmp.SelectBehavior.Select })

  keys = vim.tbl_extend("force", keys, keymaps or {})

  return vim.tbl_map(function(value)
    return cmp.mapping(value, modes)
  end, keys)
end
return {
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local keymaps = gen_mappings({ "i", "s" })

      opts.mapping = vim.tbl_extend("force", opts.mapping, keymaps)
      opts.completion = {
        completeopt = "menu,menuone,noselect",
      }
    end,
  },
  {
    "hrsh7th/cmp-cmdline",
    keys = { ":", "/", "?" },
    dependencies = { "hrsh7th/nvim-cmp" },
    config = function()
      local cmp = require("cmp")
      local keymaps = cmp.mapping.preset.cmdline(gen_mappings({ "c" }, {
        ["<C-p>"] = reset_mapping,
        ["<C-n>"] = reset_mapping,
      }))

      -- `/` cmdline setup.
      cmp.setup.cmdline({ "/", "?" }, {
        completion = { completeopt = "menu,menuone,noselect" },
        mapping = keymaps,
        sources = {
          { name = "buffer" },
        },
      })
      -- `:` cmdline setup.
      cmp.setup.cmdline(":", {
        completion = { completeopt = "menu,menuone,noselect" },
        mapping = keymaps,
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          {
            name = "cmdline",
            option = {
              ignore_cmds = { "Man", "!" },
            },
          },
        }),
      })
    end,
  },
}
