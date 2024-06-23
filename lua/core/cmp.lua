local function has_words_before()
  local line, col = (unpack or table.unpack)(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
end
local function is_visible(cmp) return cmp.core.view:visible() or vim.fn.pumvisible() == 1 end

-- stylua: ignore
return {
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp, luasnip = require "cmp", require("luasnip")

      table.insert(opts.sources, { name = "lazydev", group_index = 0 })

      opts.formatting = {
        fields = { "abbr", "kind", "menu" },
        format = function(entry, vim_item)
          local kind = require("lspkind").cmp_format { mode = "symbol_text" }(entry, vim_item)
          local strings = vim.split(kind.kind, "%s", { trimempty = true })
          kind.kind = "  " .. (strings[1] or "") .. ""
          kind.menu = " (" .. (strings[2] or "") .. ")"
          return kind
        end,
      }
      opts.window = {
        completion = cmp.config.window.bordered {
          border = "",
          winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
          scrolloff = 1,
          scrollbar = false,
        },
      }
      opts.view = { docs = { auto_open = false } }
      opts.completion = { completeopt = "menu,menuone,popup" }

      opts.mapping["<C-P>"] = nil
      opts.mapping["<C-N>"] = nil
      opts.mapping["<C-Space>"] = nil
      opts.mapping["<C-Y>"] = nil
      opts.mapping["<C-E>"] = nil

      opts.mapping["<C-J>"] = cmp.mapping(function(fallback)
        if has_words_before() then
          if is_visible(cmp) then cmp.select_next_item { behavior = cmp.SelectBehavior.Insert }
          else cmp.complete() end
        else
          if is_visible(cmp) then cmp.abort() end
          fallback()
        end
      end, { "i", "s" })

      opts.mapping["<C-K>"] = cmp.mapping(function(fallback)
        if has_words_before() then
          if is_visible(cmp) then cmp.select_prev_item { behavior = cmp.SelectBehavior.Insert }
          else cmp.complete() end
        else
          if is_visible(cmp) then cmp.abort() end
          fallback()
        end
      end, { "i", "s" })

      opts.mapping["<Tab>"] = cmp.mapping(function(fallback)
        if luasnip.locally_jumpable(1) then luasnip.jump(1)
        else fallback() end
      end, { "i", "s" })

      opts.mapping["<S-Tab>"] = cmp.mapping(function(fallback)
        if luasnip.locally_jumpable(-1) then luasnip.jump(-1)
        else fallback() end
      end, { "i", "s" })

      opts.mapping["<C-U>"] = cmp.mapping(function(fallback)
        if is_visible(cmp) and cmp.visible_docs() then cmp.scroll_docs(-4) else fallback() end
      end, { "i", "s" })

      opts.mapping["<C-D>"] = cmp.mapping(function(fallback)
        if is_visible(cmp) and cmp.visible_docs() then cmp.scroll_docs(4) else fallback() end
      end, { "i", "s" })

      opts.mapping["<C-/>"] = cmp.mapping(function(fallback)
        if is_visible(cmp) then if cmp.visible_docs() then cmp.close_docs() else cmp.open_docs() end
        else fallback() end
      end, { "i", "s" })

      opts.mapping["<C-C>"] = cmp.mapping(function(fallback)
        if is_visible(cmp) then cmp.abort() else fallback() end
      end, { "i", "s" })

      return opts
    end,
  },
  {
    "hrsh7th/cmp-cmdline",
    keys = { ":", "/", "?" },
    dependencies = { "hrsh7th/nvim-cmp", "hrsh7th/cmp-nvim-lua" },
    opts = function()
      local cmp = require "cmp"

      local mappings = {
        ["<C-C>"] = cmp.mapping(function(fallback)
          if is_visible(cmp) then cmp.abort() else fallback() end
        end, { "c" }),

        ["<C-J>"] = cmp.mapping(function()
          if is_visible(cmp) then cmp.select_next_item { behavior = cmp.SelectBehavior.Insert }
          else cmp.complete() end
        end, { "c" }),

        ["<C-K>"] = cmp.mapping(function()
          if is_visible(cmp) then cmp.select_prev_item { behavior = cmp.SelectBehavior.Insert }
          else cmp.complete() end
        end, { "c" }),

        ["<Tab>"] = cmp.mapping(function(fallback)
          if is_visible(cmp) then
            if #cmp.get_entries() and not cmp.get_selected_entry() then cmp.select_next_item() end
            cmp.confirm()
          else fallback() end
        end, { "c" }),

        ["<CR>"] = cmp.mapping(cmp.mapping.confirm(), { "c" }),
      }

      local formatting = { fields = { "abbr" } }
      local completion = { completeopt = "menu,menuone,noselect" }

      return {
        {
          type = { "/", "?" },
          mapping = mappings,
          formatting = formatting,
          completion = completion,
          sources = { { name = "buffer" } },
        },
        {
          type = ":",
          mapping = mappings,
          formatting = formatting,
          completion = completion,
          sources = {
            { name = "cmdline", option = { ignore_cmds = { "Man", "!" } }, group_index = 1 },
            { name = "nvim_lua", group_index = 2 },
            { name = "lazydev", group_index = 2 },
            { name = "path", group_index = 2 }
          }
        },
      }
    end,
    config = function(_, opts)
      local cmp = require "cmp"
      vim.tbl_map(function(val) cmp.setup.cmdline(val.type, val) end, opts)
    end,
  },
  
}
