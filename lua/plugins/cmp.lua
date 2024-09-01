-- Not all LSP servers add brackets when completing a function.
-- To better deal with this, LazyVim adds a custom option to cmp,
-- that you can configure. For example:
--
-- ```lua
-- opts = {
--   auto_brackets = { "python" }
-- }
-- ```
return {
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require("cmp")
      local keymappings = {}
      -- local auto_select = true

      keymappings["<C-e>"] = function(fallback)
        if LazyVim.cmp.visible() then
          cmp.abort()
        else
          fallback()
        end
      end
      -- keymappings["<CR>"] = LazyVim.cmp.confirm({ select = auto_select })

      keymappings = vim.tbl_map(function(value)
        return cmp.mapping(value, { "i" })
      end, keymappings)

      -- opts.completion = { completeopt = "menu,menuone,noinsert" .. (auto_select and "" or ",noselect") }
      -- opts.preselect = auto_select and cmp.PreselectMode.Item or cmp.PreselectMode.None
      opts.mapping = vim.tbl_extend("force", opts.mapping, keymappings)
    end,
  },
  {
    "hrsh7th/cmp-cmdline",
    keys = { ":", "/", "?" },
    dependencies = { "hrsh7th/nvim-cmp" },
    config = function()
      local cmp = require("cmp")
      local keymappings = {}

      keymappings["<C-e>"] = function(fallback)
        if LazyVim.cmp.visible() then
          cmp.abort()
        else
          fallback()
        end
      end

      keymappings = vim.tbl_map(function(value)
        return cmp.mapping(value, { "c" })
      end, keymappings)

      keymappings = cmp.mapping.preset.cmdline(keymappings)

      -- `/` cmdline setup.
      cmp.setup.cmdline({ "/", "?" }, {
        completion = { completeopt = "menu,menuone,noinsert,noselect" },
        preselect = cmp.PreselectMode.None,
        mapping = keymappings,
        sources = {
          { name = "buffer" },
        },
      })
      -- `:` cmdline setup.
      cmp.setup.cmdline(":", {
        completion = { completeopt = "menu,menuone,noinsert,noselect" },
        preselect = cmp.PreselectMode.None,
        mapping = keymappings,
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
