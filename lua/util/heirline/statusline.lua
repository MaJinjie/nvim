local icons = require("config.theme").icons
--=============================== config
local colors = {
  section = {
    { fg = "black", bg = "light4" },
    { fg = "light1", bg = "dark2" },
    { fg = "light1", bg = "dark1" },
    [0] = { bg = "dark1" },
  },
  mode = {
    normal = { bg = "light4", fg = "black", bold = true },
    insert = { bg = "bright_blue", fg = "black", bold = true },
    visual = { bg = "bright_yellow", fg = "black", bold = true },
    select = { bg = "bright_aqua", fg = "black", bold = true },
    replace = { bg = "bright_purple", fg = "black", bold = true },
    command = { bg = "bright_orange", fg = "black", bold = true },
    terminal = { bg = "bright_green", fg = "black", bold = true },
  },
  diagnostic = {
    error = { fg = "bright_red" },
    warn = { fg = "bright_yellow" },
    info = { fg = "bright_blue" },
    hint = { fg = "bright_aqua" },
  },
  branch = {},
  recording_macro = { fg = "bright_yellow", bold = true },
  diff = {
    added = { fg = "bright_green" },
    changed = { fg = "bright_orange" },
    removed = { fg = "bright_red" },
  },
  lsp = {
    active = { fg = "bright_green", bold = true },
  },
  background = { bg = "dark1" },
}

local separators = {
  section = { left = "", right = "" }, -- 设置分隔符
  component = { left = "  ", right = "  " }, -- 设置组件间分隔符
  padding = { left = " ", right = " " },
}

--=============================== utils
local utils = require("util.heirline.utils")

--- 连接多个sections
---@param sections table[]
---@param opts? {position?:"left"|"right", padding?:any}
function utils.sections(sections, opts)
  if #sections == 0 then
    return sections
  end

  opts = opts or {}

  local position = opts.position or "left"

  local res = {
    init = function(self)
      local si, ei, step, last, i

      -- 从后往前遍历
      if position == "left" then
        si, ei, step = #self, 1, -1
      else
        si, ei, step = 1, #self, 1
      end

      i, last = #self, 0
      for ii = si, ei, step do
        local child = self[ii]

        child.hl = child.hl or colors.section[i]
        if utils.find(child, {}) then
          if child:local_("_last_component_idx") ~= last then
            if child:local_("_force_update") then
              child._win_cache = nil
            end
            child._last_component_idx = last
          end
          last = i
        end
        i = i - 1
      end
    end,
  }

  local padding = opts.padding
  local dir = position == "left" and "right" or "left"
  for i = 1, #sections do
    table.insert(
      res,
      utils.padding(utils.padding(sections[i], padding), {
        [dir] = separators.section[position],
        hl = function(self)
          return {
            fg = self:nonlocal("merged_hl").bg,
            bg = colors.section[self:nonlocal("_last_component_idx")].bg,
          }
        end,
      })
    )
  end

  return res
end

--=============================== components
local components = {}
setmetatable(components, {
  __call = function(_, name, opts)
    local first = false
    return vim.tbl_extend("keep", opts or {}, {
      init = function(self)
        if not first then
          self[1] = self:new(components[name]())
          first = true
        end
      end,
    })
  end,
})

---占位符
function components.fill()
  return { provider = "%=" }
end

function components.empty()
  return { provider = "" }
end

--=============================== components.cache

--=============================== components.default
components.default = {}

function components.default.mode(flag)
  local vi_mode = {
    init = function(self)
      self.mode = vim.fn.mode(1)
      local mode = ""
      for k, _ in pairs(self.mode_names) do
        if self.mode:match("^" .. k) and #k > #mode then
          mode = k
        end
      end
      self.mode = mode
    end,
    static = {
      _force_update = true,
      mode_names = {
        n = { "NORMAL", "N" },
        no = { "O-PENDING", "O" },
        ni = { "I-NORMAL", "N" },
        nt = { "T-NORMAL", "N" },
        v = { "VISUAL", "v" },
        V = { "V-LINE", "V" },
        ["\22"] = { "V-BLOCK", "" },
        s = { "SELECT", "s" },
        S = { "S-LINE", "S" },
        ["\19"] = { "S-BLOCK", "" },
        i = { "INSERT", "I" },
        R = { "REPLACE", "R" },
        c = { "COMMAND", "C" },
        t = { "TERMINAL", "T" },
      },
      mode_colors = {
        n = colors.mode.normal,
        no = colors.mode.normal,
        ni = colors.mode.normal,
        nt = colors.mode.normal,
        v = colors.mode.visual,
        V = colors.mode.visual,
        ["\22"] = colors.mode.visual,
        s = colors.mode.select,
        S = colors.mode.select,
        ["\19"] = colors.mode.select,
        i = colors.mode.insert,
        R = colors.mode.replace,
        c = colors.mode.command,
        t = colors.mode.terminal,
        [""] = colors.mode.none,
      },
    },
    hl = function(self)
      return self.mode_colors[self.mode]
    end,
    update = { "ModeChanged", pattern = "*:*" },
    {
      flexible = 5,
      {
        provider = function(self)
          return self.mode_names[self.mode][1]
        end,
      },
      {
        provider = function(self)
          return self.mode_names[self.mode][2]
        end,
      },
    },
  }

  if flag == false then
    local _vi_mode = {}
    for _, field in pairs({ "static", "init", "hl", "update" }) do
      _vi_mode[field] = vi_mode[field]
    end
    vi_mode = _vi_mode
  end
  return vi_mode
end

---获取git分支
function components.default.branch()
  return {
    condition = function()
      return vim.b.gitsigns_head ~= nil
    end,
    hl = colors.branch,
    provider = function()
      return icons.misc.branch .. vim.b.gitsigns_head
    end,
  }
end

function components.default.diff()
  return {
    condition = function()
      return vim.b.gitsigns_status and vim.b.gitsigns_status ~= ""
    end,
    {
      condition = function()
        return vim.b.gitsigns_status_dict.added > 0
      end,
      provider = function()
        return icons.git.added .. vim.b.gitsigns_status_dict.added
      end,
      hl = colors.diff.added,
    },
    {
      condition = function()
        return vim.b.gitsigns_status_dict.changed > 0
      end,
      provider = function()
        return icons.git.changed .. vim.b.gitsigns_status_dict.changed
      end,
      hl = colors.diff.changed,
    },
    {
      condition = function()
        return vim.b.gitsigns_status_dict.removed > 0
      end,
      provider = function()
        return icons.git.removed .. vim.b.gitsigns_status_dict.removed
      end,
      hl = colors.diff.removed,
    },
  }
end

---获取当前文件的root
function components.default.dir()
  local dir_icon = {
    init = function(self)
      self.icon, self.icon_hl = require("mini.icons").get("directory", self.dir)
    end,
    provider = function(self)
      return self.icon and self.icon .. " " or ""
    end,
    hl = function(self)
      return self.icon_hl
    end,
  }
  local dir_name = {
    provider = function(self)
      local dir_name = vim.fn.fnamemodify(self.dir, ":t")
      return dir_name
    end,
  }
  return {
    init = function(self)
      self.dir = require("util.root").root({ follow = true })
    end,
    dir_icon,
    dir_name,
  }
end

---获取当前文件名
function components.default.file()
  local file_icon = {
    init = function(self)
      self.icon, self.icon_hl = require("mini.icons").get("file", self.file)
    end,
    provider = function(self)
      return self.icon and self.icon .. " " or ""
    end,
    hl = function(self)
      return self.icon_hl
    end,
  }
  local file_name = {
    provider = function(self)
      local filename = vim.fn.fnamemodify(self.file, ":t")
      if filename == "" then
        return "[No Name]"
      end
      return filename
    end,
  }
  local file_flags = {
    {
      condition = function()
        return vim.bo.modified
      end,
      provider = "●",
      hl = { fg = "bright_green" },
    },
    {
      condition = function()
        return not vim.bo.modifiable or vim.bo.readonly
      end,
      provider = "",
      hl = { fg = "bright_orange" },
    },
  }
  return {
    init = function(self)
      self.file = vim.api.nvim_buf_get_name(0)
    end,
    condition = function()
      return vim.bo.buftype == ""
    end,
    file_icon,
    file_name,
    file_flags,
  }
end

function components.default.file_type()
  local file_icon = {
    init = function(self)
      self.icon, self.icon_hl = require("mini.icons").get("extension", vim.api.nvim_buf_get_name(0))
    end,
    provider = function(self)
      return self.icon and self.icon .. " " or ""
    end,
    hl = function(self)
      return self.icon_hl
    end,
  }
  local file_type = {
    provider = function()
      return vim.bo.filetype
    end,
  }
  return {
    condition = function()
      return vim.bo.buftype == "" and vim.bo.filetype ~= nil and vim.bo.filetype ~= ""
    end,
    file_icon,
    file_type,
  }
end

function components.default.active_lsp()
  return {
    condition = function()
      return #vim.lsp.get_clients({ bufnr = 0 }) > 0
    end,
    update = { "LspAttach", "LspDetach" },
    provider = function()
      local names = {}
      for _, server in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
        table.insert(names, server.name)
      end
      return " [" .. table.concat(names, ",") .. "]"
    end,
    hl = colors.lsp.active,
  }
end

---获取当前文件的诊断信息

function components.default.diagnostic(cat)
  local severities = { "ERROR", "WARN" }
  local diagnostic = {
    condition = function()
      -- 检查诊断是否启用，并且有对应的诊断条目
      return vim.diagnostic.is_enabled({ bufnr = 0 }) and #vim.diagnostic.get(0, { severity = severities }) > 0
    end,
    update = { "DiagnosticChanged", "BufEnter" },
  }

  local diag_components = {}
  -- 遍历 severities，动态生成子组件
  for _, severity in ipairs(severities) do
    table.insert(diag_components, {
      condition = function(self)
        local diagnostics = vim.diagnostic.get(0, { severity = vim.diagnostic.severity[severity:upper()] })
        if #diagnostics > 0 then
          self.count = #diagnostics
          return true
        end
        return false
      end,
      provider = function(self)
        return icons.diagnostic[severity:upper()] .. self.count
      end,
      hl = colors.diagnostic[severity:lower()],
    })
  end
  return vim.tbl_extend("keep", diagnostic, utils.concat(diag_components, { separator = " " }))
end

function components.default.recording_macro()
  local macro = {
    condition = function()
      return vim.fn.reg_recording() ~= ""
    end,
    update = { "RecordingEnter", "RecordingLeave" },
    hl = colors.recording_macro,
    provider = function(self)
      vim.print(self.id)
      return " [recording @" .. vim.fn.reg_recording() .. "]"
    end,
  }
  return macro
end

function components.default.showcmd()
  vim.o.showcmd = true
  vim.o.showcmdloc = "statusline"
  local showcmd = {
    provider = "%2(%S%)",
  }
  return showcmd
end

---获取标尺
function components.default.rule()
  local rule = { provider = "%2l:%-2c" }
  local percentage = { provider = "%3P" }
  return {
    {
      flexible = 3,
      utils.concat({ rule, percentage }, { separator = separators.component.right }),
      rule,
    },
  }
end

setmetatable(components.default, {
  __call = function(self)
    return {
      hl = colors.background,
      -- left
      utils.sections({
        -- 1
        self.mode(),
        -- 2
        utils.concat({
          self.branch(),
          self.diff(),
        }, { separator = separators.component.left, condition = true }),
        self.diagnostic(),
      }, { padding = true }),
      components.fill(),
      {
        fallthrough = false,
        self.recording_macro(),
        self.active_lsp(),
      },
      components.fill(),
      utils.sections({
        -- 	-- -2
        self.file_type(),
        -- 	-- -1
        vim.tbl_extend("force", self.mode(false), self.rule()),
      }, { padding = true, position = "right" }),
    }
  end,
})

--=============================== components.lazy
components.lazy = {}

setmetatable(components.lazy, {
  __call = function(_)
    local stats = require("lazy").stats()
    local lazy_text = {
      provider = "Lazy 󰒲 ",
      hl = colors.mode.normal,
    }
    local loaded = {
      provider = ("loaded: %d/%d"):format(stats.loaded, stats.count),
    }
    local startuptime = {
      provider = ("startuptime: %.2fms"):format(stats.startuptime),
    }

    return {
      hl = colors.background,
      utils.sections({ lazy_text, loaded, startuptime }, { padding = true }),
      components.fill(),
    }
  end,
})

--=============================== components.fzf
components.fzf = {}
setmetatable(components.fzf, {
  __call = function(_)
    local text = { hl = colors.mode.select, provider = "FZF" }
    return { utils.sections({ text }, { padding = true }), components.fill() }
  end,
})

--=============================== components.oil
components.oil = {}
setmetatable(components.oil, {
  __call = function(_)
    local cwd = {
      provider = function()
        local ok, oil = pcall(require, "oil")
        return ok and vim.fs.normalize(vim.fn.fnamemodify(oil.get_current_dir(), ":~")) or ""
      end,
    }
    return { utils.sections({ cwd }, { padding = true }), components.fill() }
  end,
})

--=============================== components.netrw
components.netrw = {}
setmetatable(components.netrw, {
  __call = function(_)
    local cwd = {
      provider = function()
        return vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
      end,
    }
    return { utils.sections({ cwd }, { padding = true }), components.fill() }
  end,
})

--=============================== setup
local M = {}

M.init = function()
  M.config = {
    hl = colors.background,
    fallthrough = false,
    components("lazy", {
      condition = function()
        return vim.bo.filetype == "lazy"
      end,
    }),
    components("fzf", {
      condition = function()
        return vim.bo.filetype == "fzf"
      end,
    }),
    components("oil", {
      condition = function()
        return vim.bo.filetype == "oil"
      end,
    }),
    components("netrw", {
      condition = function()
        local ft = vim.bo.filetype
        return ft == "netrw" or ft == "neo-tree"
      end,
    }),
    components("default"),
  }
end

M.setup = function() end

return M
