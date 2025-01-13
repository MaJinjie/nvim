---@diagnostic disable: missing-fields
local M = {}

---@param component StatusLine
---@param opts? {left?:string, right?:string, hl?:any}|any
function M.padding(component, opts)
  if opts == false then
    return component
  end

  opts = type(opts) ~= "table" and { left = " ", right = " " } or opts

  if component.provider then
    local new = { provider = component.provider }
    component.provider = nil
    if #component > 0 then
      for i = 1, #component do
        table.insert(new, component[i])
        component[i] = nil
      end
    end
    table.insert(component, new)
  end

  if opts.left then
    table.insert(component, 1, { provider = opts.left, condition = false, hl = opts.hl })
  end

  if opts.right then
    table.insert(component, { provider = opts.right, condition = false, hl = opts.hl })
  end
  return component
end

---@param component StatusLine
---@param opts? {left?:any, right?:any, hl?:any}
function M.surround(component, opts)
  if opts == false then
    return component
  end

  opts = type(opts) ~= "table" and { left = " ", right = " " } or opts
  ---@cast opts table

  local res = { component }

  if opts.left then
    table.insert(res, 1, { provider = opts.left, hl = opts.hl, condition = false })
  end
  if opts.right then
    table.insert(res, { provider = opts.right, hl = opts.hl, condition = false })
  end
  return res
end

---@param components StatusLine[]
---@param opts {separator:any,padding?:boolean,handle?:function,condition?:boolean}
function M.concat(components, opts)
  if #components == 0 then
    return components
  end
  local res = {}

  local separator_condition = function(self)
    local id = self.id[#self.id]

    local parent_component = getmetatable(self)
    local prev_component = parent_component:get({ id - 1 })
    local next_component = parent_component:get({ id + 1 })

    return M.find(prev_component, { only_root = true }) and M.find(next_component, { only_root = true })
  end

  for i = 1, #components do
    if i > 1 then
      table.insert(res, {
        provider = opts.separator,
        condition = separator_condition,
      })
    end
    table.insert(res, M.padding(opts.handle and opts.handle(components[i]) or components[i], opts.padding == true))
  end

  if opts.condition then
    res.condition = function(self)
      return M.find(self, { is_root = false, is_recursive = false })
    end
  end

  return res
end

---@param self StatusLine
function M.is_condition(self)
  local condition = self.condition
  if condition == false or (type(condition) == "function" and not condition(self)) then
    return false
  end
  return true
end

---@param self StatusLine
function M.is_display(self)
  return M.is_condition(self) and self.provider and true or nil
end

---@param component StatusLine
---@param opts {is_root?:boolean,is_recursive?:boolean,only_root?:boolean,func?:(fun(self?:StatusLine):boolean)|string}
function M.find(component, opts)
  local func = type(opts.func) == "string" and M[opts.func] or opts.func or M.is_condition

  if opts.is_root ~= false then
    local ret = func(component)
    if opts.only_root or ret ~= nil then
      return ret == true
    end
  end

  for _, child in ipairs(component) do
    if M.find(child, { only_root = opts.is_recursive == false }) then
      return true
    end
  end

  return false
end

function M.make_tablist(...)
  return require("heirline.utils").make_tablist(...)
end

function M.make_buflist(...)
  return require("heirline.utils").make_buflist(...)
end

return setmetatable({}, { __index = M })
