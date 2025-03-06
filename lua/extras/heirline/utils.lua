local M = setmetatable({}, { __index = require("heirline.utils") })

---@param cat string
---@param name string
function M.icon(cat, name)
  local ok, module = pcall(require, "mini.icons")
  if ok then
    return module.get(cat, name)
  end
  return cat == "directory" and "󰉋" or "󰈔"
end

--- Encode a position to a single value that can be decoded later
---@param line integer line number of position
---@param col integer column number of position
---@param winnr integer a window number
---@return integer position the encoded position
function M.encode_pos(line, col, winnr)
  return bit.bor(bit.lshift(line, 16), bit.lshift(col, 6), winnr)
end

--- Decode a previously encoded position to it's sub parts
---@param c integer the encoded position
---@return integer line, integer column, integer window
function M.decode_pos(c)
  return bit.rshift(c, 16), bit.band(bit.rshift(c, 6), 1023), bit.band(c, 63)
end

---@param clear? boolean
local function copy_kv(dest, src, clear)
  for k, v in pairs(src) do
    if type(k) ~= "number" then
      dest[k] = dest[k] or v
      if clear then
        src[k] = nil
      end
    end
  end
end

---@param component _.heirline.component
function M.generate_components(component)
  if type(component) ~= "table" then
    component = { component }
  end
  if #component == 0 or (#component == 1 and type(component[1]) ~= "table") then
    return M.handlers(component, opts)
  end

  local ret = {} ---@type any[]
  for _, c in ipairs(component) do
    ret[#ret + 1] = M.generate_components(c)
  end
  copy_kv(ret, component)
  return M.handlers(ret)
end

M.handlers = setmetatable({}, {
  __call = function(self, component)
    -- log("=================")
    -- log("before:\n", component)
    -- vim.print("=============")
    -- vim.print(component)
    local ret = self["args"](component, component["args"])
    for _, name in ipairs({ "childs", "gap", "padding" }) do
      if ret[name] then
        ret = self[name](ret, ret[name])
        ret[name] = nil
      end
    end
    ret["args"] = nil
    -- log("after:\n", ret)
    -- log("=================")
    return ret
  end,
})

---@param component _.heirline.component
---@param opts? table
function M.handlers.args(component, opts)
  if type(component[1]) == "string" then
    component[1] = require("extras.heirline.components")[component[1]]
  end

  if type(component[1]) ~= "function" then
    return component
  end
  local flexible = component.flexible
  component.flexible = nil

  local ret = component[1](opts)
  copy_kv(ret, component)
  if flexible then
    ret = { ret, {}, flexible = flexible }
  end
  return ret
end

--- 展开
---@param component _.heirline.component
---@param opts _.heirline.component
function M.handlers.childs(component, opts)
  local childs = M.generate_components(opts)
  childs = #childs == 0 and { childs } or childs

  for _, child in ipairs(childs) do
    table.insert(component, child)
  end
  return component
end

---@param component _.heirline.component
---@param opts number|string
function M.handlers.gap(component, opts)
  if type(component) ~= "table" or #component <= 1 then
    return component
  end

  local gap = type(opts) == "number" and string.rep(" ", opts) or opts
  -- 如果gap的下一个组件条件不成立，则取消gap
  local gap_condition = function(self)
    local id = self.id[#self.id]

    local parent_component = getmetatable(self)
    local prev_component, next_component

    -- 第一个gap特殊
    if id - 1 == 1 then
      prev_component = parent_component:get({ id - 1 })
    end
    next_component = parent_component:get({ id + 1 })

    return (not prev_component or not prev_component.condition or prev_component:condition())
      and (not next_component.condition or next_component:condition())
  end

  -- log("===========")
  -- log(components)
  local ret = { component[1] }
  for i = 2, #component do
    if not vim.list_contains({ "align", "space" }, component[1].name) then
      table.insert(ret, { provider = gap, condition = gap_condition })
    end
    table.insert(ret, component[i])
  end

  copy_kv(ret, component)
  return ret
end

---@param component _.heirline.component
---@param opts {left?:number, right?:number}
function M.handlers.padding(component, opts)
  if component.provider then
    table.insert(component, 1, { provider = component.provider })
    component.provider = nil
  end
  if opts.left then
    table.insert(component, 1, { provider = string.rep(" ", opts.left) })
  end
  if opts.right then
    table.insert(component, { provider = string.rep(" ", opts.right) })
  end
  return component
end

---@param opts {left?: string, right?: string, hl?: any}
function M.handlers.surround(component, opts)
  local ret = { component }

  if opts.left then
    table.insert(ret, 1, { provider = opts.left, hl = opts.hl })
  end
  if opts.right then
    table.insert(ret, { provider = opts.right, hl = opts.hl })
  end
  return ret
end

function M.generate_colors(colors)
  local ret = {}

  local function generate_color(color)
    if type(color) == "number" then
      return color
    elseif type(color) == "string" then
      if color:sub(1, 1) == "#" then
        return color
      else
        local dot_idx = color:find(".", 1, true)
        local hl_group = dot_idx and color:sub(1, dot_idx - 1) or color
        local attr = dot_idx and color:sub(dot_idx + 1) or "fg"

        return vim.api.nvim_get_hl(0, { name = hl_group, link = false })[attr]
      end
    else
      User.util.error("Function gennerate_color error!")
    end
  end

  for name, color in pairs(colors) do
    if type(color) == "function" then
      color = color()
    end
    if type(color) ~= "table" then
      color = { color }
    end

    --- @cast color any[]
    for _, c in ipairs(color) do
      c = generate_color(c)
      if c then
        ret[name] = c
        break
      end
    end
  end

  return ret
end

return M

---@class _.heirline.handler.opts
---@field args? table 如果组件是函数，传递给组件
---@field childs? _.heirline.component 指定组件的孩子
---@field padding? {left?:number, right?:number} 填充空白
---@field gap? number 为多个组件添加间隔
