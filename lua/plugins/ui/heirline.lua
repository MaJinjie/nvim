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
          { "path", args = { props = { "icon", "name" }, type = "cwd", cat = "directory", mods = ":~" } },
          -- { { "path", args = { props = { " ", "icon", "name", "flags" }, type = "file", cat = "file", mods = ":~:." } }, {}, flexible = 1 },
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
      local filetypes = { exclude = false }

      if #buftypes > 0 and vim.list_contains(buftypes, vim.bo[args.buf].buftype) == buftypes.exclude then
        return true
      end
      if #filetypes > 0 and vim.list_contains(filetypes, vim.bo[args.buf].filetype) == filetypes.exclude then
        return true
      end
      return false
    end,
    colors = {
      bg = { "StatusLine", "bg" },
      bright_bg = { "Folded", "bg" },

      red = { "DiagnosticError", "fg" },
      yellow = { "DiagnosticWarn", "fg" },
      green = { "String", "fg" },
      blue = { "Function", "fg" }, -- #7AA2F7
      gray = { "NonText", "fg" },
      orange = { "Constant", "fg" },
      purple = { "Statement", "fg" },
      cyan = { "Special", "fg" },

      diagnostic_error = { "DiagnosticError", "fg" },
      diagnostic_warn = { "DiagnosticWarn", "fg" },
      diagnostic_info = { "DiagnosticInfo", "fg" },
      diagnostic_hint = { "DiagnosticHint", "fg" },

      git_added = { "GitSignsAdd", "fg" },
      git_changed = { "GitSignsChange", "fg" },
      git_removed = { "GitSignsDelete", "fg" },
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
