local M = {}

M.filter_find = {
  { find = '^".*" $' },
  { find = "^Already at oldest change$" },
  { find = "%d+L, %d+B" },
  { find = "; after #%d+" },
  { find = "; before #%d+" },
}

return {
  "folke/noice.nvim",
  lazy = false,
  priority = 1000,
  ---@module 'noice'
  ---@type NoiceConfig|{}
  opts = {
    cmdline = {
      format = {
        cmdline = { pattern = "^:", icon = "", lang = "vim" },
        search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
        search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
        filter = { pattern = "^:!", icon = "$", lang = "bash" },
        lua = false,
        help = false,
        calculator = { pattern = "^=", icon = "", lang = "vimnormal" },
        input = { view = "cmdline_input", icon = "󰥻 " }, -- Used by input()
      },
    },
    lsp = {
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
    },
    commands = {
      command = {
        view = "popup",
        opts = { enter = true, format = "detail" },
        cmdline = true,
        filter = { event = "msg_show", ["not"] = { any = M.filter_find } },
        filter_opts = { count = 1 },
      },
      commands = {
        view = "popup",
        opts = { enter = true, format = "details" },
        cmdline = true,
        filter = { event = "msg_show", ["not"] = { any = M.filter_find } },
        filter_opts = { reverse = true },
      },
      error = {
        view = "popup",
        opts = { enter = true, format = "detail" },
        filter = { error = true },
        filter_opts = { count = 1 },
      },
      errors = {
        view = "popup",
        opts = { enter = true, format = "details" },
        filter = { error = true },
        filter_opts = { reverse = true },
      },
      warning = {
        view = "popup",
        opts = { enter = true, format = "detail" },
        filter = { warning = true },
        filter_opts = { count = 1 },
      },
      warnings = {
        view = "popup",
        opts = { enter = true, format = "details" },
        filter = { warning = true },
        filter_opts = { reverse = true },
      },
      notify = {
        view = "popup",
        opts = { enter = true, format = "detail" },
        filter = { event = "notify" },
        filter_opts = { count = 1 },
      },
      notifs = {
        view = "popup",
        opts = { enter = true, format = "details" },
        filter = { event = "notify" },
        filter_opts = { reverse = true },
      },
      message = {
        view = "popup",
        opts = { enter = true, format = "detail" },
        filter = { kind = "message" },
        filter_opts = { count = 1 },
      },
      messages = {
        view = "popup",
        opts = { enter = true, format = "details" },
        filter = { kind = "message" },
        filter_opts = { reverse = true },
      },
      lsp = {
        view = "popup",
        opts = { enter = true, format = "detail" },
        filter = { event = "lsp", kind = "message" },
        filter_opts = { count = 1 },
      },
      lsps = {
        view = "popup",
        opts = { enter = true, format = "details" },
        filter = { event = "lsp", kind = "message" },
        filter_opts = { reverse = true },
      },
      all = {
        view = "popup",
        opts = { enter = true, format = "details" },
        filter = {
          any = {
            { event = "notify" },
            { error = true },
            { warning = true },
            { event = "msg_show", kind = { "" } },
            { event = "lsp", kind = "message" },
          },
        },
      },
    },
    format = {
      detail = {
        "{date}\n",
        "{level}\n",
        "{event}",
        { "{kind}", before = { ".", hl_group = "NoiceFormatKind" } },
        "\n",
        "{title}\n",
        "{cmdline}\n",
        "{message}",
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

    { "<leader>nc", function() require("noice").cmd("command") end, desc = "Noice Last Command" },
    { "<leader>nC", function() require("noice").cmd("commands") end, desc = "Noice Commands" },
    { "<leader>ne", function() require("noice").cmd("error") end, desc = "Noice Last Error" },
    { "<leader>nE", function() require("noice").cmd("errors") end, desc = "Noice Errors" },
    { "<leader>nw", function() require("noice").cmd("warning") end, desc = "Noice Last Warning" },
    { "<leader>nW", function() require("noice").cmd("warnings") end, desc = "Noice Warnings" },
    { "<leader>nn", function() require("noice").cmd("notify") end, desc = "Noice Last Notify" },
    { "<leader>nN", function() require("noice").cmd("notifs") end, desc = "Noice Notifs" },
    { "<leader>nm", function() require("noice").cmd("message") end, desc = "Noice Last Message" },
    { "<leader>nM", function() require("noice").cmd("messages") end, desc = "Noice Messages" },
    { "<leader>nl", function() require("noice").cmd("lsp") end, desc = "Noice Last Lsp" },
    { "<leader>nL", function() require("noice").cmd("lsps") end, desc = "Noice Lsps" },
    { "<leader>na", function() require("noice").cmd("all") end, desc = "Noice All" },
    { "<leader>nh", function() require("noice").cmd("history") end, desc = "Noice History" },

    { "<c-f>", function() if not require("noice.lsp").scroll(4) then return "<c-f>" end end, silent = true, expr = true, desc = "Scroll Forward", mode = { "i", "n", "s" } },
    { "<c-b>", function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end, silent = true, expr = true, desc = "Scroll Backward", mode = { "i", "n", "s" } },

    { "<leader>sN", function() require("noice").cmd("pick") end, desc = "Noice Picker" },
    { "<leader>uN", function() require("noice").cmd("dismiss") end, desc = "Dismiss All" },
  },
}
