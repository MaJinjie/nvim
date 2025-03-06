return {
  "saghen/blink.cmp",
  version = false,
  build = "cargo build --release",
  event = { "InsertEnter", "CmdlineEnter" },
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = {
      preset = "none",
      ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-l>"] = { "cancel", "fallback_to_mappings" },
      ["<Cr>"] = { "accept", "fallback" },

      ["<Tab>"] = { "snippet_forward", "select_and_accept", "fallback" },
      ["<S-Tab>"] = { "snippet_backward", "fallback" },

      ["<C-p>"] = { "select_prev", "fallback_to_mappings" },
      ["<C-n>"] = { "select_next", "fallback_to_mappings" },
      ["<C-b>"] = { "scroll_documentation_up", "fallback" },
      ["<C-f>"] = { "scroll_documentation_down", "fallback" },
    },
    completion = {
      list = { selection = { preselect = false } },
      menu = {
        draw = {
          treesitter = { "lsp" },
          columns = { { "kind_icon" }, { "label", "label_description", gap = 1 }, { "source_name" } },
        },
      },
      ghost_text = { enabled = true, show_without_menu = true },
    },
    appearance = { kind_icons = User.config.icons.lsp },
    signature = {
      enabled = false,
      window = {
        show_documentation = true,
      },
    },
    cmdline = {
      enabled = true,
      keymap = {
        preset = "none",
        ["<Tab>"] = {
          -- 1. 如果智能匹配却非精确匹配
          -- 2. 如果补全列表项的个数为1
          function(cmp)
            if cmp.is_active() and not cmp.is_menu_visible() then
              local items = cmp.get_items()
              local keyword = require("blink.cmp.completion.list").context:get_keyword()

              if #items == 0 then
                return
              end

              return (keyword == items[1].sortText and keyword ~= items[1].filterText or #items == 1)
                and cmp.select_and_accept()
            end
          end,
          "show_and_insert",
          "select_next",
        },
        ["<S-Tab>"] = { "show_and_insert", "select_prev" },
        ["<C-l>"] = { "cancel", "fallback_to_mappings" },
      },
      completion = {
        menu = {
          draw = {
            columns = { { "label", "label_description", gap = 1 } },
          },
        },
        ghost_text = { enabled = true },
      },
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
      providers = {},
    },
  },
}
