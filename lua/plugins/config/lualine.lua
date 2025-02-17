local colors = require("tokyonight.colors").setup()
local icons = LazyVim.config.icons
local conditions = {}
local components = {}

--================================= conditions =====================================
function conditions.buffer_not_empty()
  return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
end

function conditions.hide_in_width()
  return vim.fn.winwidth(0) > 80
end

function conditions.check_git_workspace()
  local filepath = vim.fn.expand("%:p:h")
  local gitdir = vim.fn.finddir(".git", filepath .. ";")
  return gitdir and #gitdir > 0 and #gitdir < #filepath
end

--================================= components =====================================
function components.left()
  return {
    function()
      return "▊"
    end,
    color = { fg = colors.blue }, -- Sets highlighting of component
    padding = { left = 0, right = 1 }, -- We don't need space before this
  }
end

function components.mode()
  local mode_names = { -- change the strings if you like it vvvvverbose!
    n = "N",
    no = "N?",
    nov = "N?",
    noV = "N?",
    ["no\22"] = "N?",
    niI = "Ni",
    niR = "Nr",
    niV = "Nv",
    nt = "Nt",
    v = "V",
    vs = "Vs",
    V = "V_",
    Vs = "Vs",
    ["\22"] = "^V",
    ["\22s"] = "^V",
    s = "S",
    S = "S_",
    ["\19"] = "^S",
    i = "I",
    ic = "Ic",
    ix = "Ix",
    R = "R",
    Rc = "Rc",
    Rx = "Rx",
    Rv = "Rv",
    Rvc = "Rv",
    Rvx = "Rv",
    c = "C",
    cv = "Ex",
    r = "...",
    rm = "M",
    ["r?"] = "?",
    ["!"] = "!",
    t = "T",
  }

  local mode_colors = {
    n = colors.red,
    no = colors.red1,
    i = colors.blue,
    v = colors.green,
    V = colors.green1,
    [""] = colors.green2,
    c = colors.orange,
    s = colors.magenta2,
    S = colors.magenta2,
    [""] = colors.magenta2,
    R = colors.magenta,
    r = colors.purple,
    ["!"] = colors.cyan,
    t = colors.teal,
  }

  return {
    -- mode component
    function()
      return " " .. mode_names[vim.fn.mode(true)] or mode_names[vim.fn.mode()]
    end,
    color = function()
      return { fg = mode_colors[vim.fn.mode(true)] or mode_colors[vim.fn.mode()] }
    end,
    padding = { right = 1 },
  }
end

function components.filesize()
  return {
    -- filesize component
    "filesize",
    cond = conditions.buffer_not_empty,
  }
end

function components.filename()
  return {
    "filename",
    cond = conditions.buffer_not_empty,
    color = { fg = colors.magenta, gui = "bold" },
  }
end

function components.location()
  return { "progress" }
end

function components.progress()
  local sbar = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" }
  -- Another variant, because the more choice the better.
  -- sbar = { '🭶', '🭷', '🭸', '🭹', '🭺', '🭻' }

  return {
    function()
      local curr_line = vim.api.nvim_win_get_cursor(0)[1]
      local lines = vim.api.nvim_buf_line_count(0)
      local i = math.floor((curr_line - 1) / lines * #sbar) + 1
      return string.rep(sbar[i], 2)
    end,
    color = { fg = colors.fg, gui = "bold" },
  }
end

function components.diagnostics()
  return {
    "diagnostics",
    symbols = {
      error = icons.diagnostics.Error,
      warn = icons.diagnostics.Warn,
      info = icons.diagnostics.Info,
      hint = icons.diagnostics.Hint,
    },
  }
end

function components.fill()
  return { "%=" }
end

function components.lsp_servers()
  return {
    -- Lsp server name .
    function()
      local names = {}
      for _, server in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
        table.insert(names, server.name)
      end
      return table.concat(names, ",")
    end,
    icon = " LSP:",
    color = { fg = "#ffffff", gui = "bold" },
    cond = function()
      return #vim.lsp.get_clients({ bufnr = 0 }) > 0
    end,
  }
end

function components.encoding()
  return {
    "o:encoding", -- option component same as &encoding in viml
    fmt = string.upper, -- I'm not sure why it's upper case either ;)
    cond = conditions.hide_in_width,
    color = { fg = colors.green, gui = "bold" },
  }
end

function components.fileformat()
  return {
    "fileformat",
    fmt = string.upper,
    icons_enabled = false, -- I think icons are cool but Eviline doesn't have them. sigh
    color = { fg = colors.green, gui = "bold" },
  }
end

function components.branch()
  return {
    "branch",
    icon = "",
    color = { fg = colors.orange, gui = "bold" },
  }
end

function components.diff()
  return {
    "diff",
    -- Is it me or the symbol for modified us really weird
    symbols = { added = icons.git.added, modified = icons.git.modified, removed = icons.git.removed },
    source = function()
      local gitsigns = vim.b.gitsigns_status_dict
      if gitsigns then
        return {
          added = gitsigns.added,
          modified = gitsigns.changed,
          removed = gitsigns.removed,
        }
      end
    end,
    cond = conditions.hide_in_width,
  }
end

function components.right()
  return {
    function()
      return "▊"
    end,
    color = { fg = colors.blue },
    padding = { left = 1 },
  }
end

return {
  options = {
    component_separators = "",
    section_separators = "",
  },
  sections = {
    -- these are to remove the defaults
    lualine_a = {},
    lualine_b = {},
    lualine_y = {},
    lualine_z = {},
    -- These will be filled later
    lualine_c = {
      components.left(),
      components.mode(),
      components.branch(),
    },
    lualine_x = {
      components.location(),
      components.right(),
    },
  },
}
