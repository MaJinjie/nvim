return {
  {
    "onsails/lspkind.nvim",
    opts = {
      mode = "symbol",
      symbol_map = {
        Array = "󰅪",
        Boolean = "⊨",
        Class = "󰌗",
        Constructor = "",
        Key = "󰌆",
        Namespace = "󰅪",
        Null = "NULL",
        Number = "#",
        Object = "󰀚",
        Package = "󰏗",
        Property = "󰜢",
        Reference = "",
        Snippet = "",
        String = "󰀬",
        TypeParameter = "󰊄",
        Unit = "",
      },
    },
  },
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require "cmp"

      -- vim.api.nvim_set_hl(0, "Pmenu", { bg = "#22252A", fg = "NONE" })
      -- vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#569CD6", fg = "NONE" })

      vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { bg = "NONE", fg = "#569CD6" })
      vim.api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzy", { link = "CmpIntemAbbrMatch" })
      vim.api.nvim_set_hl(0, "CmpItemMenu", { fg = "#C792EA", bg = "NONE", italic = true })

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

      opts.mapping["<A-K>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "s" })
      opts.mapping["<A-J>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "s" })
      opts.mapping["<C-Z>"] = cmp.mapping(function()
        if cmp.visible() then
          cmp.abort()
        else
          cmp.complete()
        end
      end, { "i", "s" })
      return opts
    end,
  },
  {
    "hrsh7th/cmp-cmdline",
    keys = { ":", "/", "?" }, -- lazy load cmp on more keys along with insert mode
    dependencies = { "hrsh7th/nvim-cmp", "hrsh7th/cmp-nvim-lua" },
    opts = function()
      local cmp = require "cmp"
      local cmdline_mappings = {
        ["<C-Z>"] = cmp.mapping(function()
          if cmp.visible() then
            cmp.abort()
          else
            cmp.complete()
          end
        end, { "c" }),
        ["<Tab>"] = cmp.mapping(function()
          if cmp.visible() then
            cmp.select_next_item()
          else
            cmp.complete()
          end
        end, { "c" }),
        ["<S-Tab>"] = cmp.mapping(function()
          if cmp.visible() then
            cmp.select_prev_item()
          else
            cmp.complete()
          end
        end, { "c" }),
        ["<C-J>"] = cmp.mapping(cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert }, { "c" }),
        ["<C-K>"] = cmp.mapping(cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert }, { "c" }),
        ["<CR>"] = cmp.mapping(cmp.mapping.confirm { select = false }, { "c" }),
      }

      return {
        {
          type = { "/", "?" },
          mapping = cmdline_mappings,
          sources = {
            { name = "buffer" },
          },
        },
        {
          type = ":",
          mapping = cmdline_mappings,
          sources = cmp.config.sources({
            { name = "path" },
          }, {
            {
              name = "cmdline",
              option = {
                ignore_cmds = { "Man", "!" },
              },
            },
          }, { { name = "nvim_lua" } }),
        },
      }
    end,
    config = function(_, opts)
      local cmp = require "cmp"
      vim.tbl_map(function(val) cmp.setup.cmdline(val.type, val) end, opts)
    end,
  },
}
