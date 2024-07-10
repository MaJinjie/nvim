local M = {}
local mappings

function M.swap(mode_mappings, key1, key2)
  if mode_mappings[key1] and mode_mappings[key2] then
    mode_mappings[key1], mode_mappings[key2] = mode_mappings[key2], mode_mappings[key1]
  else
    vim.notify("key1 or key2 is not exists", vim.log.levels.ERROR)
  end
end

---comment
---@param modes string
---@return boolean
local function is_modes(modes)
  local vim_modes = require("config").modes
  return string.match(modes, string.format("^[%s]+$", table.concat(vim_modes)))
end

---comment
---@param modes string
---@param from_mappings table<string, table>
---@param opts table
local function handle_mappings(modes, from_mappings, opts)
  if vim.tbl_isempty(from_mappings) then
    vim.notify("from_mappings must a table", vim.log.levels.ERROR)
    return
  end
  if not is_modes(modes) then
    vim.notify(modes .. " is not vim modes", vim.log.levels.ERROR)
    return
  end

  local error_picker = vim.me.log.error_mappings[opts.behavior]

  for i = 1, modes:len() do
    local mode = modes:sub(i, i)
    local to_mappings = mappings[mode]

    for key, value in pairs(from_mappings) do
      if error_picker.have == not to_mappings[key] then
        if error_picker.notify then
          vim.notify(
            string.format(
              "plugin: %s\nmode: %s\nkey: %s\nbehavior: %s\nfrom_desc: %s\nto_desc: %s",
              opts.plugin,
              mode,
              key,
              string.format("%s {have=%s, override=%s}", opts.behavior, error_picker.have, error_picker.override),
              value.desc,
              to_mappings[key] and to_mappings[key].desc or ""
            ),
            error_picker.level
          )
        end
        -- error mappings log => vim.me.log.error_mappings
        error_picker[mode] = error_picker[mode] or {}
        table.insert(error_picker[mode], key)

        if error_picker.override then to_mappings[key] = value end
      else
        to_mappings[key] = value
      end
    end
  end
end

---comment
---@param from_mappings table<string, table>
---@param opts table
local function check_modes(from_mappings, opts)
  if opts.modes ~= "" then
    handle_mappings(opts.modes, from_mappings, opts)
  else
    for key, value in pairs(from_mappings) do
      if type(key) == "number" then
        vim.notify("from_mappings:key shouldn't a number", vim.log.levels.WARN)
      else
        handle_mappings(key, value, opts)
      end
    end
  end
end

local handler = { behavior = "keep", modes = "", plugin = "" }
setmetatable(handler, {
  --- comment
  --- @param v table|string mappings | behavior
  __call = function(t, v)
    if type(v) == "table" then
      check_modes(v, t)
    elseif type(v) == "string" then
      -- 深度拷贝实现继承
      local copy_handler = vim.deepcopy(handler)
      rawset(copy_handler, "behavior", v)
      return copy_handler
    else
      vim.notify("type(param) must mappings or behavior", vim.log.levels.ERROR)
    end
  end,

  --- comment
  --- @param k string modes
  --- @param v table mappings
  __newindex = function(t, k, v)
    local old_modes = rawget(t, "modes")
    rawset(t, "modes", k)
    check_modes(v, t)
    rawset(t, "modes", old_modes)
  end,

  --- comment
  --- @param k string modes
  __index = function(t, k)
    local copy_handler = vim.deepcopy(t)
    rawset(copy_handler, "modes", k)
    return copy_handler
  end,
})

-- local set = vim.me.keymap("from_mappings", "opts")
-- set {}
-- set.n = {}
-- set("force") {}
-- set('force') .n = {}
-- local nset = vim.me.keymap("from_mappings", "opts").n
-- nset {}
-- nset("force") {}

-- 隐藏handler中的成员
return setmetatable(M, {
  __call = function(_, plugin, opts)
    mappings = opts.mappings

    local copy_handler = vim.deepcopy(handler)
    copy_handler.plugin = plugin
    return copy_handler
  end,
  __index = function(_, k) vim.notify(k .. " field is not exists", vim.log.levels.WARN) end,
})
