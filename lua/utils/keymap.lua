-- 全局唯一一个存储按键与行为映射关系的表
local g_keymappings = {}
local g_swap_keys = {}
local g_override_keymappings = {}
local M = {}

-- module
local notifier = require "utils.notify" {
  title = "My Key Mappings",
}

--- comment
--- @param mode string One char mode
--- @return boolean: is a mode
local function is_mode(mode)
  if mode:len() ~= 1 then return false end
  local modes = { "n", "x", "o", "v", "c", "i" }
  return vim.list_contains(modes, mode)
end

---comment
---@param in_mode string One char mode Or modes table
---@param in_keymappings table keymappings table
---@return table: mode-mappings
local function get_mappings(in_mode, in_keymappings)
  vim.validate {
    in_mode = { in_mode, is_mode, "请输入正确的模式" },
    in_keymappings = { in_keymappings, "t" },
  }
  in_keymappings[in_mode] = in_keymappings[in_mode] or {}
  return in_keymappings[in_mode]
end

---comment
---@param in_modes string|string[] One Char mode Or modes Table
---@param in_mappings table mode-mappings
---@param in_keymappings table keymappings Table
local function handle_mappings(in_modes, in_mappings, in_keymappings)
  vim.validate {
    in_modes = { in_modes, { "s", "t" } },
    in_mappings = { in_mappings, "t" },
    in_keymappings = { in_keymappings, "t" },
  }
  in_modes = type(in_modes) == "string" and { in_modes } or in_modes
  ---@cast in_modes string[]

  for _, mode in ipairs(in_modes) do
    local mappings = get_mappings(mode, in_keymappings)

    for key, value in pairs(in_mappings) do
      mappings[key] = value
    end
  end
end

---将输入的keymappings与模块中记录的keymappings进行合并。
---合并内容包括：合并添加键、删除键以及交换键
---
---@param in_keymappings table 要合并输入keymappings
---@return table: 合并完成后的keymappings
function M.merge_mappings(in_keymappings)
  vim.validate {
    in_keymappings = { in_keymappings, "t" },
  }
  local ret_keymappings = in_keymappings or {}

  for mode, mappings in pairs(g_keymappings) do
    local ret_mappings = get_mappings(mode, ret_keymappings)
    local override_mappings = get_mappings(mode, g_override_keymappings)
    for key, mapping in pairs(mappings) do
      if ret_mappings[key] and mapping ~= false then override_mappings[key] = ret_mappings[key] end
      ret_mappings[key] = mapping
    end
  end

  for mode, keys in pairs(g_swap_keys) do
    local ret_mappings = get_mappings(mode, ret_keymappings)
    for lkey, rkey in pairs(keys) do
      if ret_mappings[rkey] then
        ret_mappings[lkey], ret_mappings[rkey] = ret_mappings[rkey], ret_mappings[lkey]
      else
        notifier.error(string.format("要求 %s 存在，否则 %s 行为不合法", rkey, lkey))
      end
    end
  end

  return ret_keymappings
end

---记录映射键
---
---@param in_modes string|string[] 模式或模式组成的列表
---@param in_mappings table<string, table|string> key-mapping表
local function set_mappings(in_modes, in_mappings) handle_mappings(in_modes, in_mappings, g_keymappings) end

---删除映射键
---
---@param in_modes string|string[] 模式或模式组成的列表
---@param in_mappings table<string, boolean> key-false表
local function del_mappings(in_modes, in_mappings)
  in_mappings = require("utils").tbl_assign(false, in_mappings)
  handle_mappings(in_modes, in_mappings, g_keymappings)
end

---交换映射键
---
---@param in_modes string|string[] 模式或模式组成的列表
---@param in_mappings table<string, string> lkey-rkey表
local function swap_mappings(in_modes, in_mappings) handle_mappings(in_modes, in_mappings, g_swap_keys) end

---设置全局的映射表
---
---@param in_keymappings table 接受的全局映射表
---@return table: 旧的表
function M.set_keymappings(in_keymappings)
  vim.validate { mappings = { in_keymappings, "t" } }
  local old_mappings = g_keymappings
  g_keymappings = in_keymappings
  return old_mappings
end

---获取全局的映射表
---
---@return table: 全局映射表
function M.get_keymappings() return g_keymappings end

---报告覆盖映射键
---
---@param opts table notify的选项
function M.report_override_mappings(opts)
  vim.validate { opts = { opts, "t", true } }
  notifier.warn(vim.inspect(g_override_keymappings), opts)
end

--- 工厂
--- 以统一形式调用set del swap
---
--- @param func function
--- @return table
local function factory(func)
  return setmetatable({}, {
    __call = function(_, keymappings)
      for modes, mappings in pairs(keymappings) do
        func(modes, mappings)
      end
    end,
    __index = function(_, in_modes)
      return function(in_mappings) func(in_modes, in_mappings) end
    end,
    __newindex = function(_, in_modes, in_mappings) func(in_modes, in_mappings) end,
  })
end

M.set = factory(set_mappings)
M.del = factory(del_mappings)
M.swap = factory(swap_mappings)

return M
