---@type LazySpec
return {
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp, luasnip = require "cmp", require "luasnip"
      local user_opts = {}

      table.insert(opts.sources, { name = "lazydev", group_index = 0 })

      user_opts = {
        experimental = { ghost_text = true },
        completion = { completeopt = "menu,menuone" },
        view = { docs = { auto_open = false } },

        formatting = {
          fields = { "abbr", "kind", "menu" },
          format = function(entry, vim_item)
            local kind = require("lspkind").cmp_format { mode = "symbol_text" }(entry, vim_item)
            local strings = vim.split(kind.kind, "%s", { trimempty = true })
            kind.kind = "  " .. (strings[1] or "") .. ""
            kind.menu = " (" .. (strings[2] or "") .. ")"
            return kind
          end,
        },
        window = {
          completion = cmp.config.window.bordered {
            border = "",
            -- winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
            scrolloff = 1,
            -- scrollbar = false,
            -- zindex = 100,
          },
        },
      }

      user_opts.mapping = {
        ["<C-P>"] = nil,
        ["<C-N>"] = nil,
        ["<C-Space>"] = nil,
        ["<C-Y>"] = nil,
        ["<C-E>"] = nil,
        ["<C-J>"] = cmp.mapping(function()
          if cmp.visible() then
            cmp.select_next_item { behavior = cmp.SelectBehavior.Insert }
            if not cmp.get_selected_entry() then cmp.abort() end
          else
            cmp.complete()
          end
        end, { "i", "s" }),
        ["<C-K>"] = cmp.mapping(function()
          if cmp.visible() then
            cmp.select_prev_item { behavior = cmp.SelectBehavior.Insert }
            if not cmp.get_selected_entry() then cmp.abort() end
          else
            cmp.complete()
            if #cmp.get_entries() > 1 then
              cmp.select_prev_item { behavior = cmp.SelectBehavior.Insert }
              cmp.select_prev_item { behavior = cmp.SelectBehavior.Insert }
            end
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
          if cmp.visible() and cmp.visible_docs() then
            cmp.scroll_docs(-4)
          else
            fallback()
          end
        end, { "i", "s" }),

        ["<C-D>"] = cmp.mapping(function(fallback)
          if cmp.visible() and cmp.visible_docs() then
            cmp.scroll_docs(4)
          else
            fallback()
          end
        end, { "i", "s" }),

        ["<C-/>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
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
          if cmp.visible() then
            cmp.abort()
          else
            fallback()
          end
        end, { "i", "s", "c" }),

        ["<CR>"] = cmp.mapping(cmp.mapping.confirm(), { "i", "s" }),
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

      user_opts = {
        formatting = { fields = { "abbr" } },
        completion = { completeopt = "menu,menuone,noselect" },
      }
      user_opts.mapping = {
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            if #cmp.get_entries() and not cmp.get_selected_entry() then cmp.select_next_item() end
            cmp.confirm()
          else
            fallback()
          end
        end, { "c" }),
        ["<C-J>"] = cmp.mapping(function()
          if cmp.visible() then
            cmp.select_next_item { behavior = cmp.SelectBehavior.Insert }
          else
            cmp.complete()
          end
        end, { "c" }),
        ["<C-K>"] = cmp.mapping(function()
          if cmp.visible() then
            cmp.select_prev_item { behavior = cmp.SelectBehavior.Insert }
          else
            cmp.complete()
          end
        end, { "c" }),
      }

      return user_opts
    end,
    config = function(_, opts)
      local cmp = require "cmp"

      for type, sources in pairs {
        ["/"] = cmp.config.sources {
          { name = "buffer" },
        },
        ["?"] = {
          { name = "buffer" },
        },
        [":"] = {
          { name = "cmdline", option = { ignore_cmds = { "Man", "!" } }, group_index = 1 },
          { name = "nvim_lua", group_index = 2 },
          { name = "path", group_index = 2 },
        },
      } do
        cmp.setup.cmdline(type, vim.tbl_extend("keep", opts, { sources = sources }))
      end
    end,
  },

  {
    "L3MON4D3/LuaSnip",
    opts = {
      snip_env = {},
    },
    specs = {
      "AstroNvim/astrocore",
      opts = {
        commands = {
          LuaSnipEdit = {
            function(_args)
              local snippet_sources, snippet_filetypes = {}, {}

              for _, arg in ipairs(_args.fargs) do
                local source = string.match(arg, "source=(%a+)")
                if source then
                  table.insert(snippet_sources, source)
                elseif not _args.bang then
                  table.insert(snippet_filetypes, arg)
                end
              end

              if #snippet_sources == 0 then snippet_sources = { "lua" } end
              if #snippet_filetypes == 0 and not _args.bang then snippet_filetypes = { vim.bo.filetype } end

              require("luasnip.loaders").edit_snippet_files {
                ft_filter = function(filetype)
                  if #snippet_filetypes then
                    return vim.tbl_contains(snippet_filetypes, filetype, {})
                  else
                    return true
                  end
                end,
                format = function(_file, _source)
                  if not vim.tbl_contains(snippet_sources, _source) then return nil end
                  local prefix = vim.fn.stdpath "config" .. "/snippets/"
                  return string.sub(_file, 1, #prefix) == prefix and _file or nil
                end,
              }
            end,
            desc = "Edit snippets",
            nargs = "*",
            bang = true,
            complete = function(_arg, _cmd, _pos)
              local completions = {
                source = { "lua", "vscode", "snipmate" },
              }

              for k, v in pairs(completions) do
                if k == string.match(_arg, "(%a+)=") then return v end
              end
              return vim.tbl_map(function(_value) return _value .. "=" end, vim.tbl_keys(completions))
            end,
          },
        },
      },
    },
    config = function(plugin, opts)
      -- include the default astronvim config that calls the setup call
      require "astronvim.plugins.configs.luasnip"(plugin, opts)
      -- load snippets paths
      for _, type in ipairs { "vscode", "snipmate", "lua" } do
        require("luasnip.loaders.from_" .. type).lazy_load {
          paths = { vim.fn.stdpath "config" .. "/snippets/" .. type },
        }
      end
    end,
  },
}
