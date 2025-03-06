local M = {}
local conditions = require("extras.heirline.conditions")
local utils = require("extras.heirline.utils") 

---@param opts {direction: "left"|"right"}
function M.sidebar(opts)
  local provider = (opts.direction == "left" and "▊") or (opts.direction == "right" and "▊")
  return {
    provider = provider,
    hl = { fg = "blue" },
  }
end

function M.align()
  return { provider = "%=" }
end

function M.space()
  return { provider = " " }
end

---@param opts string|{content: string}
function M.text(opts)
  if type(opts) == "string" then
    opts = { content = opts }
  end

  return {
    update = function() return false end,
    provider = opts.content,
  }
end

function M.mode()
  return {
    init = function(self)
      self.mode = vim.fn.mode(1) -- :h mode()
    end,
    static = {
      mode_names = {
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
      },
      mode_colors = {
        n = "red",
        i = "green",
        v = "purple",
        V = "purple",
        ["\22"] = "purple",
        c = "orange",
        s = "cyan",
        S = "cyan",
        ["\19"] = "cyan",
        R = "orange",
        r = "orange",
        ["!"] = "red",
        t = "green",
      },
    },
    provider = function(self)
      return " %2(" .. self.mode_names[self.mode] .. "%)"
    end,
    hl = function(self)
      local mode = self.mode:sub(1, 1) -- get only the first mode character
      return { fg = self.mode_colors[mode], bold = true }
    end,
    update = {
      "ModeChanged",
      pattern = "*:*",
      callback = vim.schedule_wrap(function()
        vim.cmd("redrawstatus")
      end),
    },
  }
end

function M.branch()
  return {
    condition = conditions.is_git_repo,
    provider = function()
      local icon, branch = " ", nil
      if vim.b.gitsigns_head ~= nil then
        branch = vim.b.gitsigns_head
      else
        branch = vim.fn.system(("git -C %s branch --show-current"):format(vim.fn.expand("%:h"))):gsub("\n$", "")
      end
      return icon .. branch
    end,
    hl = { fg = "orange" },
  }
end

function M.diff()
  local kinds = { "added", "changed", "removed" }

  local childs = {}
  for _, kind in ipairs(kinds) do
    local child = {
      condition = function()
        return vim.b.gitsigns_status_dict[kind] > 0
      end,
      provider = function()
        return User.config.icons.git[kind] .. vim.b.gitsigns_status_dict[kind]
      end,
      hl = { fg = "git_" .. kind },
    }
    table.insert(childs, child)
  end

  return { condition = conditions.has_diff, unpack(childs) }
end

local path_component = {}

path_component.icon = {
  init = function(self)
    self.icon, self.icon_hl = utils.icon(self:get("cat"), self:get("path"))
  end,
  provider = function(self)
    return self.icon and self.icon .. " " or ""
  end,
  hl = function(self)
    return self.icon_hl
  end,
}
path_component.type = {
  provider = function()
    return vim.bo.filetype
  end,
}
path_component.flags = {
  {
    condition = conditions.file_is_modified,
    provider = " ●",
    hl = { fg = "green" },
  },
  {
    condition = conditions.file_is_readonly,
    provider = " ",
    hl = { fg = "orange" },
  },
}
path_component.name = {
  provider = function(self)
    local filename = self:get("path")
    local mods, short = self:get("mods"), self:get("short")
    if filename == "" then
      return "[No Name]"
    end

    if mods then
      filename = vim.fn.fnamemodify(filename, mods)
    end
    if short then
      filename = vim.fn.pathshorten(filename, short)
    end
    return filename
  end,
}
path_component.size = {
  provider = function(self)
    local path = self:get("path")
    -- stackoverflow, compute human readable file size
    local suffix = { "b", "k", "M", "G", "T", "P", "E" }
    local fsize = vim.fn.getfsize(path)
    fsize = (fsize < 0 and 0) or fsize
    if fsize < 1024 then
      return fsize .. suffix[1]
    end
    local i = math.floor((math.log(fsize) / math.log(1024)))
    return string.format("%.2g%s", fsize / math.pow(1024, i), suffix[i + 1])
  end,
}
path_component.encoding = {
  provider = function()
    local enc = (vim.bo.fenc ~= "" and vim.bo.fenc) or vim.o.enc -- :h 'enc'
    return enc ~= "utf-8" and enc:upper()
  end,
}
path_component.format = {
  provider = function()
    local fmt = vim.bo.fileformat
    return fmt ~= "unix" and fmt:upper()
  end,
}

local path_type = {
  file = function(bufnr)
    return vim.api.nvim_buf_get_name(bufnr or 0)
  end,
  cwd = function(scope)
    return User.root.cwd(scope or "w")
  end,
  root = function(opts)
    return User.root.get(opts or { follow = "buffer" })
  end,
}

---@param opts _.heirline.path.opts
function M.path(opts)
  local ret = {
    condition = opts.type == "file" and conditions.is_file or nil,
    static = {
      args = setmetatable({}, { __index = opts }),
      get = function(self, key)
        return self.args[key]
      end,
      set = function(self, key, value)
        self.args[key] = value
      end,
    },
    init = function(self)
      self:set("path", path_type[self:get("type")](self:get("opts")))
    end,
  }

  for _, prop in ipairs(opts.props) do
    local component = path_component[prop]
    if component then
      table.insert(ret, component)
    else
      table.insert(ret, { provider = prop })
    end
  end

  return ret
end

---@param opts? {provider: user.heirline.source.Provider[]}
function M.sources(opts)
  opts = opts or {}
  opts.provider = opts.provider or { "lsp" }

  return {
    condition = function(self)
      local ok, map = conditions.has_sources(opts)
      self.map = map
      return ok
    end,
    update = { "LspAttach", "LspDetach", "BufEnter" },
    provider = function(self)
      local map = self.map
      local names = {}
      for _, p in ipairs(opts.provider) do
        if map[p] then
          vim.list_extend(names, map[p])
        end
      end
      return " [" .. table.concat(names, ",") .. "]"
    end,
    hl = { fg = "green", bold = true },
  }
end

---@param opts? {severity: vim.diagnostic.Severity[]}
function M.diagnostics(opts)
  opts = opts or {}
  opts.severity = opts.severity or { "ERROR", "WARN" }

  local childs = {}
  for _, severity in ipairs(opts.severity) do
    local severity_integer = vim.diagnostic.severity[severity]
    local child = {
      condition = function(self)
        self._count = self.count[severity_integer]
        return self._count and self._count > 0
      end,
      provider = function(self)
        return User.config.icons.diagnostics[severity] .. self._count
      end,
      hl = { fg = "diagnostic_" .. severity:lower() },
    }
    table.insert(childs, child)
  end

  return {
    condition = function(self)
      local ok, count = conditions.has_diagnostics(opts)
      self.count = count
      return ok
    end,
    update = { "DiagnosticChanged", "BufEnter" },
    childs = childs,
    gap = 1,
  }
end

---@param opts? {style: "bar"|"percentage"}
function M.progress(opts)
  opts = opts or {}
  opts.style = opts.style or "bar"

  local styles = {
    bar = {
      static = {
        sbar = vim.tbl_map(function(v)
          return string.rep(v, 2)
        end, { " ", "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" }),
        -- Another variant, because the more choice the better.
        -- sbar = { '🭶', '🭷', '🭸', '🭹', '🭺', '🭻' }
      },
      provider = function(self)
        local curr_line = vim.api.nvim_win_get_cursor(0)[1]
        local lines = vim.api.nvim_buf_line_count(0)
        local i = math.floor((curr_line - 1) / lines * #self.sbar) + 1
        return self.sbar[i]
      end,
      hl = { fg = "blue", bg = "bright_bg" },
    },
    percentage = { provider = "%3P" },
  }

  return styles[opts.style]
end

function M.location()
  return { provider = "%2l:%-2c" }
end

function M.showmode()
  return {
    condition = conditions.is_recording_macro,
    provider = function()
      return " [recording @" .. vim.fn.reg_recording() .. "]"
    end,
    update = { "RecordingEnter", "RecordingLeave" },
    hl = { fg = "orange" },
  }
end

function M.extension()
  local extensions_index = {} ---@type table<string, number>

  return {
    condition = function(self)
      local name = vim.bo.filetype
      local ok, extension = pcall(require, string.format("extras.heirline.extensions.%s", name))
      if ok then
        self.name, self.extension = name, extension
      end
      return ok
    end,
    init = function(self)
      local name, extension = self.name, self.extension
      if extensions_index[name] then
        self.pick_child = { extensions_index[name] }
        return
      end

      local index = #self + 1
      self[index] = self:new(utils.generate_components(extension, { name = name }), index)
      extensions_index[name] = index
      self.pick_child = { index }
    end,
    update = { "BufWinEnter" },
  }
end

function M.showcmd()
  return {
    provider = function()
      return require("noice").api.status.command.get()
    end,
    condition = function()
      return conditions.is_available("noice.nvim") and require("noice").api.status.command.has()
    end,
    hl = { fg = "purple" },
  }
end

---@param opts? {max_depth?: number, sep?: string, ellipsis?: string, style?: "static"|"dynamic"}
function M.symbols(opts)
  opts = opts or {}
  opts.max_depth = opts.max_depth or nil
  opts.sep = opts.sep or " "
  opts.ellipsis = opts.ellipsis or ""
  opts.style = opts.style or "static"

  return {
    condition = function()
      return conditions.is_available("aerial.nvim")
    end,
    update = { "CursorMoved" },
    init = function(self)
      local symbols = require("aerial").get_location(true)
      local winnr = vim.api.nvim_win_get_number(0)
      local si, ei = 1, #symbols
      local remaining
      local childs = {}

      if opts.max_depth then
        remaining = #symbols > opts.max_depth
        si = remaining and ei - opts.max_depth + 1 or 1
      end

      for ii = si, ei do
        local symbol = symbols[ii]
        local child = {
          { provider = opts.sep },
          { provider = symbol.icon, hl = ("Aerial%sIcon"):format(symbol.kind) },
          { provider = symbol.name:gsub("%%", "%%%%"):gsub("%s*->%s*", "") },
          on_click = {
            minwid = utils.encode_pos(symbol.lnum, symbol.col, winnr),
            callback = function(_, minwid)
              local lnum, col, winnr = utils.decode_pos(minwid)
              local winid = assert(vim.fn.win_getid(winnr))
              vim.cmd("normal! m`") -- 设置跳转标记
              vim.api.nvim_win_set_cursor(winid, { lnum, col })
            end,
            name = "heirline_breadcrumbs",
          },
        }

        if opts.style == "dynamic" then
          child = {
            child,
            ii == si and si ~= ei and not remaining and { provider = opts.sep .. opts.ellipsis } or {},
            flexible = ii,
          }
        end

        table.insert(childs, child)
      end

      if remaining then
        table.insert(childs, 1, { provider = opts.sep .. opts.ellipsis })
      end
      self[1] = self:new(childs, 1)
    end,
  }
end

return M

---@class _.heirline.path.opts
---@field props "icon"|"flags"|"type"|"size"|"encoding"|"format"
---
---@field type "file"|"cwd"|"root"
---@field cat? string
---@field short? number
---@field mods? string

---@alias _.heirline.component string|function|_.heirline._component

---@class _.heirline._component: _.heirline.handler.opts,{[any]: any}
---@field [number] [_.heirline.component]
---@field name? string 组件名（会传递到StatusLine）
