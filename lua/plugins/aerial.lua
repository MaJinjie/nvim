return {
  "stevearc/aerial.nvim",
  lazy = true,
  opts = {
    placement = "window", ---@type "edge"|"window"
    attach_mode = "global", ---@type "global"|"window"
    close_automatic_events = { "unsupported" }, ---@type ("unfocus"|"switch_buffer"|"unsupported")[]

    backends = { "lsp", "treesitter", "markdown", "man" },
    layout = { min_width = 30 },
    show_guides = true,
    guides = {
      mid_item = "├ ",
      last_item = "└ ",
      nested_top = "│ ",
      whitespace = "  ",
    },
    keymaps = {
      ["J"] = "actions.down_and_scroll",
      ["K"] = "actions.up_and_scroll",
    },
    highlight_on_hover = true,
    filter_kind = User.config.kind_filter,
    icons = User.config.icons.lsp,
    on_attach = function(bufnr)
      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
      end
      map("n", "[s", function()
        require("aerial").prev(vim.v.count1)
      end, "Prev symbol")
      map("n", "]s", function()
        require("aerial").next(vim.v.count1)
      end, "Next symbol")
      map("n", "[S", function()
        require("aerial").prev_up(vim.v.count1)
      end, "Prev symbol upwards")
      map("n", "]S", function()
        require("aerial").next_up(vim.v.count1)
      end, "Next symbol upwards")
    end,
    nav = {
      min_width = { 0.3, 40 },
      min_height = { 12, 0.3 },
      preview = true,
      keymaps = {
        ["q"] = "actions.close",
      },
    },
  },
  keys = {
    { "<leader>cs", "<cmd>AerialToggle<cr>", desc = "Toggle Symbols outline" },
    { "<leader>cS", "<cmd>AerialNavToggle<cr>", desc = "Toggle Symbols nav" },
  },
}
