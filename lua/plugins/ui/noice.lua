return {
  "folke/noice.nvim",
  lazy = false,
  priority = 1000,
  ---@module 'noice'
  ---@type NoiceConfig|{}
  opts = {
    lsp = {
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
    },
    routes = {
      {
        filter = { event = "msg_show", any = { { find = "%d+L, %d+B" }, { find = "; after #%d+" }, { find = "; before #%d+" } } },
        opts = { skip = true },
        view = "mini",
      },
    },
    presets = { bottom_search = false, command_palette = true, long_message_to_split = true },
  },
  -- stylua: ignore
  keys = {
    {
      "<S-Enter>",
      function()
        local type, content = vim.fn.getcmdtype(), vim.fn.getcmdline()
        if type == ":" then
          require("noice").redirect(content)
        end
      end,
      mode = "c",
      desc = "Redirect Cmdline",
    },
    { "<leader>nl", function() require("noice").cmd("last") end, desc = "Noice Last Message" },
    { "<leader>nh", function() require("noice").cmd("history") end, desc = "Noice History" },
    { "<leader>na", function() require("noice").cmd("all") end, desc = "Noice All" },
    { "<leader>ne", function() require("noice").cmd("errors") end, desc = "Noice Picker" },
    { "<c-f>", function() if not require("noice.lsp").scroll(4) then return "<c-f>" end end, silent = true, expr = true, desc = "Scroll Forward", mode = { "i", "n", "s" } },
    { "<c-b>", function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end, silent = true, expr = true, desc = "Scroll Backward", mode = { "i", "n", "s" } },

    { "<leader>sN", function() require("noice").cmd("pick") end, desc = "Noice Picker" },
    { "<leader>uN", function() require("noice").cmd("dismiss") end, desc = "Dismiss All" },
  },
}
