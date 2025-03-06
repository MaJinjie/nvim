return {
  {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    lazy = true,
    version = "v2.*",
    build = "make install_jsregexp", -- install jsregexp
    opts = function()
      local types = require("luasnip.util.types")
      return {
        ext_opts = {
          [types.choiceNode] = {
            active = {
              virt_text = { { "●", "UserCyan" } },
            },
          },
          [types.insertNode] = {
            active = {
              virt_text = { { "●", "UserGreen" } },
            },
          },
        },
      }
    end,
    config = function(_, opts)
      require("luasnip.config").setup(opts)

      require("luasnip.loaders.from_vscode").lazy_load()
    end,
    specs = {
      "saghen/blink.cmp",
      ---@module 'blink.cmp'
      ---@type blink.cmp.Config
      opts = {
        keymap = {
          ["<Esc>"] = {
            function(cmp)
              if cmp.snippet_active() then
                return require("luasnip").unlink_current()
              end
            end,
            "fallback",
          },
        },
        snippets = {
          preset = "luasnip",
          active = function(filter)
            local ls = require("luasnip")
            if ls.expand_or_locally_jumpable() then
              return true
            end
            if filter and filter.direction then
              return ls.locally_jumpable(filter.direction)
            end
            return ls.in_snippet()
          end,
          jump = function(direction)
            local ls = require("luasnip")
            if ls.expandable() then
              return ls.expand_or_jump()
            end
            return ls.locally_jumpable(direction) and ls.jump(direction)
          end,
        },
      },
    },
  },
  { "rafamadriz/friendly-snippets", lazy = true },
}
