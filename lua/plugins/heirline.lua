return {
  "rebelot/heirline.nvim",
  lazy = vim.fn.argc(-1) == 0,
  priority = 800,
  event = "LazyFile",
  opts = {
    statusline = {
      { "sidebar", args = { direction = "left" } },
      {
        { "extension", childs = "align" },
        {
          { "mode" },
          { "branch" },
          { "path", args = { props = { "icon", "name" }, type = "file", cat = "file", mods = ":~:." }, flexible = 1 },
          { "diagnostics", args = { severity = { "ERROR", "WARN", "INFO" } } },
          "align",
          { "showmode" },
          "align",
          { "sources", args = { provider = { "lsp", "linter", "formatter" } } },
          { "location", "progress", gap = 1 },
          gap = 2,
        },
        fallthrough = false,
      },
      { "sidebar", args = { direction = "right" } },
      gap = 1,
      hl = { bg = "bg" },
    },
    winbar = {
      {
        { "path", args = { props = { "icon", "name" }, type = "root", cat = "directory", mods = ":t" } },
        { "path", args = { props = { "icon", "name" }, type = "file", cat = "extension", mods = ":t" } },
        gap = " ",
      },
      { "symbols", args = { max_depth = 6, style = "dynamic" } },
    },
    disable_winbar_cb = function(args)
      local buftypes = { "", exclude = false }
      local filetypes = { "snacks_picker_preview", "minimap", exclude = true }

      if #buftypes > 0 and vim.list_contains(buftypes, vim.bo[args.buf].buftype) == buftypes.exclude then
        return true
      end
      if #filetypes > 0 and vim.list_contains(filetypes, vim.bo[args.buf].filetype) == filetypes.exclude then
        return true
      end
      return false
    end,
    colors = {
      bg = { "StatusLine.bg" },
      bright_bg = { "Folded.fg" },

      red = { "UserRed" },
      orange = { "UserOrange" },
      yellow = { "UserYellow" },
      green = { "UserGreen" },
      cyan = { "UserCyan" },
      blue = { "UserBlue" },
      purple = { "UserPurple" },

      azure = { "UserAzure" },
      grey = { "UserGrey" },

      gray = "Comment",

      diagnostic_error = "DiagnosticError",
      diagnostic_warn = "DiagnosticWarn",
      diagnostic_info = "DiagnosticInfo",
      diagnostic_hint = "DiagnosticHint",

      git_added = "GitSignsAdd",
      git_changed = "GitSignsChange",
      git_removed = "GitSignsDelete",
    },
  },
  config = function(_, opts)
    local utils = require("extras.heirline.utils")
    require("heirline").setup({
      statusline = utils.generate_components(opts.statusline),
      winbar = utils.generate_components(opts.winbar),
      opts = { colors = utils.generate_colors(opts.colors), disable_winbar_cb = opts.disable_winbar_cb },
    })

    vim.api.nvim_create_augroup("Heirline", { clear = true })
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        utils.on_colorscheme(utils.generate_colors(opts.colors))
      end,
      group = "Heirline",
    })
  end,
}
