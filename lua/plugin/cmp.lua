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
      opts.mapping["<A-K>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "s" })
      opts.mapping["<A-J>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "s" })
      opts.mapping["<C-Z>"] = cmp.mapping(function()
        if cmp.visible() then
          cmp.abort()
        else
          cmp.complete()
        end
      end, { "i", "s" })
      opts.window.completion.border = nil
      opts.window.documentation.border = nil
      opts.formatting.fields = { "abbr", "kind" }
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
