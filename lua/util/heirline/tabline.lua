--=============================== config
local config = {
  offset = {
    left = {
      ["neo-tree"] = { title = "Neo-Tree" },
    },
    right = {},
  },
  left_trunc = { provider = " ", hl = { fg = "gray" } },
  right_trunc = { provider = " ", hl = { fg = "gray" } },
  exclude_filetype = {},
  -- include_buftype = { "" },
}
local colors = {
  background = { bg = "dark_hard" },
  bufferline = {
    active = { fg = "light_soft", bg = "dark_soft", bold = true },
    inactive = { fg = "gray" },
    visible = { fg = "light3", bg = "dark_soft" },
  },
  tabpage = {
    active = { fg = "light_soft", bg = "dark_soft" },
    inactive = { fg = "gray" },
  },
  flags = {
    modified = { fg = "bright_yellow" },
    readonly = { fg = "bright_orange" },
    close = { fg = "gray" },
  },
  picker = { fg = "bright_red", bold = true },
  offset = { fg = "bright_yellow", bg = "dark0" },
}
--=============================== utils
local utils = require("util.heirline.utils")

local buflist_cache = {} ---@type number[]
local buflist_display_cache = {} ---@type table<number, string>
local buflist_path_cache = {} ---@type table<number, string>

--=============================== components
local components = {}

function components.fill()
  return { provider = "%=" }
end

--=============================== components.offset

local function get_leaf(layout, dir)
  if layout[1] == "leaf" then
    return layout[2]
  end
  if layout[1] == "col" then
    local col = layout[2]
    return get_leaf(col[1], dir)
  else
    local row = layout[2]
    return get_leaf(dir == "left" and row[1] or row[#row], dir)
  end
end

function components.offset(dir)
  return {
    condition = function(self)
      local winid = get_leaf(vim.fn.winlayout(), dir)
      local bufnr = vim.api.nvim_win_get_buf(winid)

      self.winid = winid

      for filetype, info in pairs(config.offset[dir]) do
        if vim.bo[bufnr].filetype == filetype then
          self.info = info
          return true
        end
      end
      return false
    end,
    update = { "BufWipeout" },
    provider = function(self)
      local info = self.info
      local winid = self.winid

      local width = vim.api.nvim_win_get_width(winid)
      local pad = math.ceil((width - #info.title) / 2)
      return string.rep(" ", pad) .. info.title .. string.rep(" ", pad)
    end,
    hl = colors.offset,
  }
end

--=============================== components.bufferline
function components.bufferline()
  local file_picker = {
    condition = function(self)
      return self._show_picker and not self.is_active
    end,
    update = function()
      return false
    end,
    init = function(self)
      local bufname = vim.api.nvim_buf_get_name(self.bufnr)
      bufname = vim.fn.fnamemodify(bufname, ":t")
      local label = bufname:sub(1, 1)
      local i = 2
      while self._picker_labels[label] do
        if i > #bufname then
          break
        end
        label = bufname:sub(i, i)
        i = i + 1
      end
      self._picker_labels[label] = self.bufnr
      self.label = label
    end,
    provider = function(self)
      return self.label .. " "
    end,
    hl = colors.picker,
  }

  local file_icon = {
    init = function(self)
      self.icon, self.icon_hl = require("mini.icons").get("file", self.path)
    end,
    provider = function(self)
      return self.icon and self.icon .. " " or ""
    end,
    hl = function(self)
      return self.icon_hl
    end,
  }

  local file_name = {
    init = function(self)
      local file = self.spath or self.path

      self.basename = file == "" and "[No Name]" or vim.fs.basename(file)
      self.dirname = file ~= self.basename and vim.fs.dirname(file):gsub("^%.%/?", "", 1) or ""
    end,
    {
      condition = function(self)
        return self.dirname ~= ""
      end,
      provider = function(self)
        return self.dirname .. "/"
      end,
      hl = colors.inactive,
    },
    {
      condition = function(self)
        return self.basename ~= ""
      end,
      provider = function(self)
        return self.basename
      end,
    },
  }

  local file_flags = {
    fallthrough = false,
    {
      condition = function(self)
        return vim.bo[self.bufnr].modified
      end,
      provider = " ●",
      hl = colors.flags.modified,
    },
    {
      condition = function(self)
        return not vim.bo[self.bufnr].modifiable or vim.bo[self.bufnr].readonly
      end,
      provider = "  ",
      hl = colors.flags.readonly,
    },
    {
      provider = " 󰅖",
      hl = colors.flags.close,
      on_click = {
        callback = function(_, minwid)
          vim.schedule(function()
            require("util.keymap").buf_delete(minwid)
            vim.cmd.redrawtabline()
          end)
        end,
        minwid = function(self)
          return self.bufnr
        end,
        name = "heirline_tabline_close_buffer_callback",
      },
    },
  }

  return {
    init = function(self)
      self.path = buflist_path_cache[self.bufnr]
      self.spath = buflist_display_cache[self.bufnr]
    end,
    condition = function(self)
      return vim.bo[self.bufnr].buftype == ""
    end,
    hl = function(self)
      if self.is_active then
        return colors.bufferline.active
      elseif self.is_visible then
        return colors.bufferline.visible
      else
        return colors.bufferline.inactive
      end
    end,
    on_click = {
      callback = function(_, minwid, _, button)
        if button == "l" then
          vim.api.nvim_win_set_buf(0, minwid)
        end
      end,
      minwid = function(self)
        return self.bufnr
      end,
      name = "heirline_tabline_buffer_callback",
    },
    {
      fallthrough = false,
      file_picker,
      file_icon,
    },
    file_name,
    file_flags,
  }
end

function components.bufferlines()
  return utils.make_buflist(
    utils.padding(components.bufferline(), { left = "▎", right = " ", hl = { fg = "dark_soft" } }),
    config.left_trunc,
    config.right_trunc,
    function()
      return buflist_cache
    end,
    false
  )
end

--=============================== components.tabpage
function components.tabpage()
  return {
    provider = function(self)
      return "%" .. self.tabnr .. "T " .. self.tabnr .. " %T"
    end,
    hl = function(self)
      return self.is_active and colors.tabpage.active or colors.tabpage.inactive
    end,
  }
end
function components.tabpages()
  return {
    condition = function()
      return #vim.api.nvim_list_tabpages() >= 2
    end,
    utils.make_tablist(utils.padding(components.tabpage())),
  }
end

--=============================== setup
local M = {}

M.init = function()
  M.config = {
    hl = colors.background,
    components.offset("left"),
    components.bufferlines(),
    components.fill(),
    components.tabpages(),
    components.offset("right"),
  }
end

M.setup = function()
  local get_bufs = function()
    return vim.tbl_filter(function(bufnr)
      if not vim.api.nvim_buf_is_valid(bufnr) or not vim.bo[bufnr]["buflisted"] then
        return false
      end

      if vim.list_contains(config.exclude_filetype, vim.bo[bufnr]["filetype"]) then
        return false
      end
      return true
    end, vim.api.nvim_list_bufs())
  end

  local function simply_path(bufs, n)
    local spath_bufs = {}
    for _, buf in ipairs(bufs) do
      local spath = buflist_path_cache[buf]:match(("[^/]*/"):rep(n - 1) .. "[^/]*$")
      if spath then
        spath_bufs[spath] = spath_bufs[spath] or {}
        table.insert(spath_bufs[spath], buf)
      end
    end

    for spath, sbufs in pairs(spath_bufs) do
      if #sbufs == 1 then
        buflist_display_cache[sbufs[1]] = spath
      else
        simply_path(sbufs, n + 1)
      end
    end
  end

  vim.api.nvim_create_autocmd({ "VimEnter", "BufAdd", "BufDelete" }, {
    callback = function()
      vim.schedule(function()
        local bufs = get_bufs()

        buflist_cache = bufs
        bufs = {}
        buflist_path_cache = {}
        buflist_display_cache = {}

        for _, buf in ipairs(buflist_cache) do
          if vim.bo[buf].buftype == "" then
            table.insert(bufs, buf)
            buflist_path_cache[buf] = vim.api.nvim_buf_get_name(buf)
          end
        end

        simply_path(bufs, 1)

        if #bufs > 1 then
          vim.o.showtabline = 2 -- always
        elseif vim.o.showtabline ~= 1 then -- don't reset the option if it's already at default value
          vim.o.showtabline = 1 -- only when #tabpages > 1
        end
      end)
    end,
  })

  vim.api.nvim_create_user_command("BufferPick", function(args)
    local tabline = require("heirline").tabline
    local buflist = tabline._buflist[1]
    buflist._picker_labels = {}
    buflist._show_picker = true
    vim.cmd.redrawtabline()
    local char = vim.fn.getcharstr()
    local bufnr = buflist._picker_labels[char]
    if bufnr then
      vim.api.nvim_win_set_buf(0, bufnr)
    end
    buflist._show_picker = false
    vim.cmd.redrawtabline()
  end, { desc = "Pick a bufferline" })
end
return M
