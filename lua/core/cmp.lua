local function has_words_before()
  local line, col = (unpack or table.unpack)(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
end
local function is_visible(cmp) return cmp.core.view:visible() or vim.fn.pumvisible() == 1 end

---@type LazySpec
return {
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp, luasnip = require "cmp", require "luasnip"
      local user_opts = {}

      table.insert(opts.sources, { name = "lazydev", group_index = 0 })

      user_opts.formatting = {
        fields = { "abbr", "kind", "menu" },
        format = function(entry, vim_item)
          local kind = require("lspkind").cmp_format { mode = "symbol_text" }(entry, vim_item)
          local strings = vim.split(kind.kind, "%s", { trimempty = true })
          kind.kind = "  " .. (strings[1] or "") .. ""
          kind.menu = " (" .. (strings[2] or "") .. ")"
          return kind
        end,
      }
      user_opts.window = {
        completion = cmp.config.window.bordered {
          border = "",
          winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
          scrolloff = 1,
          scrollbar = false,
        },
      }
      user_opts.view = { docs = { auto_open = false } }
      user_opts.completion = { completeopt = "menu,menuone,popup" }

      user_opts.mapping = {
        ["<C-P>"] = nil,
        ["<C-N>"] = nil,
        ["<C-Space>"] = nil,
        ["<C-Y>"] = nil,
        ["<C-E>"] = nil,
        ["<C-J>"] = cmp.mapping(function()
          if is_visible(cmp) then
            cmp.select_next_item { behavior = cmp.SelectBehavior.Insert }
          else
            cmp.complete()
          end
        end, { "i", "s" }),
        ["<C-K>"] = cmp.mapping(function()
          if is_visible(cmp) then
            cmp.select_prev_item { behavior = cmp.SelectBehavior.Insert }
          else
            cmp.complete()
          end
        end, { "i", "s" }),

        ["<Tab>"] = cmp.mapping(function(fallback)
          if luasnip.locally_jumpable(1) then
            luasnip.jump(1)
          else
            fallback()
          end
        end, { "i", "s" }),

        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if luasnip.locally_jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),

        ["<C-U>"] = cmp.mapping(function(fallback)
          if is_visible(cmp) and cmp.visible_docs() then
            cmp.scroll_docs(-4)
          else
            fallback()
          end
        end, { "i", "s" }),

        ["<C-D>"] = cmp.mapping(function(fallback)
          if is_visible(cmp) and cmp.visible_docs() then
            cmp.scroll_docs(4)
          else
            fallback()
          end
        end, { "i", "s" }),

        ["<C-/>"] = cmp.mapping(function(fallback)
          if is_visible(cmp) then
            if cmp.visible_docs() then
              cmp.close_docs()
            else
              cmp.open_docs()
            end
          else
            fallback()
          end
        end, { "i", "s" }),

        ["<C-C>"] = cmp.mapping(function(fallback)
          if is_visible(cmp) then
            cmp.abort()
          else
            fallback()
          end
        end, { "i", "s" }),
      }

      return require("astrocore").extend_tbl(opts, user_opts)
    end,
  },
  {
    "hrsh7th/cmp-cmdline",
    keys = { ":", "/", "?" },
    dependencies = { "hrsh7th/nvim-cmp", "hrsh7th/cmp-nvim-lua" },
    opts = function()
      local cmp = require "cmp"
      local user_opts = {}

      user_opts.mapping = {
        ["<C-C>"] = cmp.mapping(function(fallback)
          if is_visible(cmp) then
            cmp.abort()
          else
            fallback()
          end
        end, { "c" }),

        ["<C-J>"] = cmp.mapping(function()
          if is_visible(cmp) then
            cmp.select_next_item { behavior = cmp.SelectBehavior.Insert }
          else
            cmp.complete()
          end
        end, { "c" }),

        ["<C-K>"] = cmp.mapping(function()
          if is_visible(cmp) then
            cmp.select_prev_item { behavior = cmp.SelectBehavior.Insert }
          else
            cmp.complete()
          end
        end, { "c" }),

        ["<Tab>"] = cmp.mapping(function(fallback)
          if is_visible(cmp) then
            if #cmp.get_entries() and not cmp.get_selected_entry() then cmp.select_next_item() end
            cmp.confirm()
          else
            fallback()
          end
        end, { "c" }),

        ["<CR>"] = cmp.mapping(cmp.mapping.confirm(), { "c" }),
      }

      user_opts.formatting = { fields = { "abbr" } }
      user_opts.completion = { completeopt = "menu,menuone,noselect" }

      return user_opts
    end,
    config = function(_, opts)
      local cmp = require "cmp"

      for type, sources in pairs {
        ["/"] = { { name = "buffer" } },
        ["?"] = { { name = "buffer" } },
        [":"] = {
          { name = "cmdline", option = { ignore_cmds = { "Man", "!" } }, group_index = 1 },
          { name = "nvim_lua", group_index = 2 },
          { name = "lazydev", group_index = 2 },
          { name = "path", group_index = 2 },
        },
      } do
        cmp.setup.cmdline(type, vim.tbl_extend("keep", opts, { sources = sources }))
      end
    end,
  },
}
