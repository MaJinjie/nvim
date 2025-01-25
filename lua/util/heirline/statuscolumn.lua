-- 1. 布局
--    1. 2 buffer flags
--    2. 2 line number
--    3. 2 window flags
-- 2. 局部渲染
-- 3. 缓存 哪些需要缓存呢？
--    1. 多个窗口可能会作为同一个缓冲区的视窗，buffer需要缓存
--    2. 窗口所持有的flag不需要缓存，因为每一个窗口在一个刷新间隔中只会计算一次
--=============================== config
local config = {
  pattern = {
    git = { "^GitSigns" },
  },
  refresh = 50,
}

---@type table<number, table<number, util.statuscolumn.Sign[]>>
local buf_cache = {}

--=============================== utils
local utils = require("util.heirline.utils")

---@param win integer
---@param clnum number
---@return util.statuscolumn.Sign[]
function utils.calc_win_signs(win, clnum)
  local signs = {}
  -- Get fold signs
  if vim.fn.foldclosed(clnum) >= 0 then
    table.insert(signs, { text = vim.opt.fillchars:get().foldclose or "", texthl = "Folded", type = "folded" })
  -- 只保留第一层次的折叠
  elseif vim.treesitter.foldexpr(clnum) == ">1" then
    table.insert(signs, { text = vim.opt.fillchars:get().foldopen or "", texthl = "Comment", type = "foldable" })
  end
  table.sort(signs, function(a, b)
    return (a.priority or 0) > (b.priority or 0)
  end)
  return signs
end

---@param str string?
---@return util.statuscolumn.Sign.type
local function get_sign_type(str)
  if str == nil or str == "" then
    return "sign"
  end
  for type, patterns in pairs(config.pattern) do
    for _, pattern in ipairs(patterns) do
      if str:find(pattern) then
        return type
      end
    end
  end
  return "sign"
end

---@param buf integer
---@param clnum number
---@return util.statuscolumn.Sign[]
function utils.calc_buf_signs(buf, clnum)
  buf_cache[buf] = buf_cache[buf] or {}

  if buf_cache[buf][clnum] and buf_cache[buf][clnum][0] then
    return buf_cache[buf][clnum]
  end

  local lsigns = buf_cache[buf]

  local function scan(slnum, elnum, step)
    for lnum = slnum, elnum, step do
      if lsigns[lnum] and lsigns[lnum][0] ~= true then
        return lnum - step
      end
      lsigns[lnum] = lsigns[lnum] or {}
      lsigns[lnum][0] = true
    end
    return elnum
  end

  -- Init number range
  local wt, wb = vim.fn.line("w0"), vim.fn.line("w$")
  local slnum = scan(clnum - 1, math.max(1, wt), -1)
  local elnum = scan(clnum, math.min(vim.fn.line("$"), wb), 1)

  -- Get extmark signs
  local extmarks = vim.api.nvim_buf_get_extmarks(
    buf,
    -1,
    { slnum - 1, 0 },
    { elnum - 1, -1 },
    { details = true, type = "sign" }
  )
  for _, extmark in ipairs(extmarks) do
    local type = get_sign_type(extmark[4].sign_hl_group)
    local text = extmark[4].sign_text
    local texthl = extmark[4].sign_hl_group
    local priority = extmark[4].priority
    local lnum = extmark[2] + 1

    table.insert(lsigns[lnum], { type = type, text = text, texthl = texthl, priority = priority })
  end
  if lsigns[0] ~= true then
    -- Get mark signs
    local marks = vim.list_extend(vim.fn.getmarklist(buf), vim.fn.getmarklist())
    for _, mark in ipairs(marks) do
      if mark.pos[1] == buf and mark.mark:match("[a-zA-Z]") then
        local lnum = mark.pos[2]
        lsigns[lnum] = lsigns[lnum] or {}
        table.insert(lsigns[lnum], { text = mark.mark:sub(2), texthl = "DiagnosticHint", type = "mark" })
      end
    end
    ---@diagnostic disable-next-line: assign-type-mismatch
    lsigns[0] = true
  end

  -- Sort by priority
  for lnum = slnum, elnum do
    table.sort(lsigns[lnum], function(a, b)
      return (a.priority or 0) > (b.priority or 0)
    end)
  end

  return lsigns[clnum]
end

---@param signs util.statuscolumn.Sign[]
---@param types util.statuscolumn.Sign.type[]
---@return util.statuscolumn.Sign?
function utils.get_sign(signs, types)
  for _, sign in ipairs(signs) do
    for _, type in ipairs(types) do
      if sign.type == type then
        return sign
      end
    end
  end
end

---@param sign? util.statuscolumn.Sign
---@param size? number
---@return util.statuscolumn.Sign
function utils.trim_sign(sign, size)
  size = size or 2
  sign = sign or {}

  local sign_text = vim.fn.strcharpart(sign.text or "", 0, size)
  sign.text = sign_text .. string.rep(" ", size - vim.fn.strchars(sign_text))
  return sign
end

--=============================== components
local components = {}

function components.space(size)
  return { provider = (" "):rep(size or 1) }
end

function components.left()
  return {
    condition = function()
      return vim.wo.signcolumn ~= "no"
    end,
    init = function(self)
      self.sign = utils.trim_sign(utils.get_sign(utils.calc_buf_signs(self.bufnr, vim.v.lnum), { "sign", "mark" }))
    end,
    provider = function(self)
      return self.sign.text
    end,
    hl = function(self)
      return self.sign.texthl
    end,
  }
end

function components.center()
  return {
    provider = function()
      if vim.o.number or vim.o.relativenumber then
        local lnum, width
        if vim.v.relnum == 0 then
          lnum = vim.o.number and vim.v.lnum or vim.v.relnum
        else
          lnum = vim.o.relativenumber and vim.v.relnum or vim.v.lnum
        end
        width = #tostring(math.max(vim.fn.line("."), vim.api.nvim_win_get_height(0)))
        return ("%" .. width .. "s"):format(lnum) .. " "
        -- return ("%-" .. (width + 1) .. "s"):format(lnum)
      end
    end,
    hl = function()
      return vim.v.relnum == 0 and "CursorLineNr" or "LineNr"
    end,
  }
end
_G["heirline_fold_on_click"] = function()
  local pos = vim.fn.getmousepos()
  vim.api.nvim_win_call(pos.winid, function()
    if vim.fn.foldclosed(pos.line) >= 0 then
      vim.cmd(pos.line .. "foldopen")
    else
      vim.cmd(pos.line .. "foldclose")
    end
  end)
end

function components.right()
  return {
    condition = function()
      return vim.wo.signcolumn ~= "no"
    end,
    init = function(self)
      self.sign = utils.get_sign(utils.calc_buf_signs(self.bufnr, vim.v.lnum), { "git" })
    end,
    hl = function(self)
      if self.sign then
        return utils.hl_info(self.sign.texthl, true)
      end
    end,
    {
      init = function(self)
        local sign = utils.trim_sign(utils.calc_win_signs(self.winnr, vim.v.lnum)[1] or self:nonlocal("sign"))
        self.sign = sign
        if not sign.type then
          return
        end
        if sign.type:match("^fold") then
          self.on_click = { callback = "v:lua.heirline_fold_on_click" }
        end
      end,
      provider = function(self)
        return self.sign.text
      end,
      hl = function(self)
        return self.sign.texthl
      end,
    },
  }
end
--=============================== setup
local M = {}

M.init = function()
  M.config = {
    condition = function()
      if vim.v.virtnum ~= 0 then
        return
      end

      return vim.v.lnum >= vim.fn.line("w0") and vim.v.lnum <= vim.fn.line("w$")
    end,
    init = function(self)
      self.bufnr = vim.api.nvim_get_current_buf()
      self.winnr = vim.api.nvim_get_current_win()
    end,
    hl = function()
      local normal_hl = vim.api.nvim_get_hl(0, { name = "Normal" })
      return { bg = normal_hl.bg, force = true }
    end,
    components.left(),
    components.center(),
    components.right(),
  }
end

M.setup = function()
  local timer = assert(vim.uv.new_timer())
  timer:start(config.refresh, config.refresh, function()
    buf_cache = {}
  end)
end
return M

---@alias util.statuscolumn.Sign.type "mark"|"sign"|"git"|"folded"|"foldable"
---@alias util.statuscolumn.Sign {text:string, texthl:string, priority:number, type:util.statuscolumn.Sign.type}
---@alias util.statuscolumn.Self {bufnr:number,winnr:number}
