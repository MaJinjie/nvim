local M = {}
M.keymap = require "utils.keymap"
M.notify = require "utils.notify"

---@param o table Table to index
---@param ... any Optional keys (0 or more, variadic) via which to index the table
---@return any # Nested value indexed by key
function M.tbl_get(o, ...)
  vim.validate { o = { o, "t" } }

  local nargs = select("#", ...)
  for i = 1, nargs do
    local k = select(i, ...)
    o[k] = o[k] or {}
    o = o[k]
  end
  return o
end

--- Apply a function to all values of a table.
---
---@generic T
---@param fv any|fun(value: T): any Any value or Function
---@param t T[] List
---@return table<T,any>  Table of transformed values
function M.tbl_assign(fv, t)
  vim.validate {
    t = { t, "t" },
  }

  local rettab = {}
  for _, v in pairs(t) do
    if type(fv) == "function" then
      rettab[v] = fv(v)
    else
      rettab[v] = fv
    end
  end
  return rettab
end

return M
