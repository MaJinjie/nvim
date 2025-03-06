_G.User = require("user")

local M = {}

---@class user.config
local config = {
  icons = {
    misc = {
      dots = "󰇘",
    },
    ft = {
      octo = "",
    },
    dap = {
      Stopped = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
      Breakpoint = " ",
      BreakpointCondition = " ",
      BreakpointRejected = { " ", "DiagnosticError" },
      LogPoint = ".>",
    },
    diagnostics = {
      ERROR = " ",
      WARN = " ",
      INFO = " ",
      HINT = " ",
    },
    git = {
      added = "+", -- " ",
      changed = "~", -- " ",
      removed = "-", -- " ",
    },
    lsp = {
      Array = " ",
      Boolean = "󰨙 ",
      Class = " ",
      Codeium = "󰘦 ",
      Color = " ",
      Control = " ",
      Collapsed = " ",
      Constant = "󰏿 ",
      Constructor = " ",
      Copilot = " ",
      Enum = " ",
      EnumMember = " ",
      Event = " ",
      Field = " ",
      File = " ",
      Folder = " ",
      Function = "󰊕 ",
      Interface = " ",
      Key = "󰌋 ",
      Keyword = " ",
      Method = " ",
      Module = "󰕳 ",
      Namespace = "󰦮 ",
      Null = " ",
      Number = "󰎠 ",
      Object = " ",
      Operator = " ",
      Package = " ",
      Property = " ",
      Reference = " ",
      Snippet = "󱄽 ",
      String = " ",
      Struct = "󰆼 ",
      Supermaven = " ",
      TabNine = "󰏚 ",
      Text = " ",
      TypeParameter = " ",
      Unit = " ",
      Value = " ",
      Variable = "󰀫 ",
    },
  },
  kind_filter = {
    default = {
      "Class",
      "Constructor",
      "Enum",
      "Field",
      "Function",
      "Interface",
      "Method",
      "Module",
      "Namespace",
      "Package",
      "Property",
      "Struct",
      "Trait",
    },
    lua = {
      "Object",
      "Method",
      "Function",
      "Field",
      "Module",
      "Array",
    },
  },
}

User.config = config

User.util.safe_require("config.options")
User.util.safe_require("config.autocmds")
User.util.safe_require("config.commands")
User.util.safe_require("config.lazy")

-- Lazy load
User.util.on_verylazy(function()
  User.root.setup()
  User.format.setup()

  User.util.safe_require("config.keymaps")
end)

-- Apply colorsheme
User.util.try(function()
  vim.cmd.colorscheme(vim.g.colorscheme)
end, {
  msg = ("Could not load %s colorscheme"):format(vim.g.colorscheme),
  on_error = function(msg)
    User.util.error(msg, { title = "apply colorscheme" })
    vim.cmd.colorscheme("habamax")
  end,
})
