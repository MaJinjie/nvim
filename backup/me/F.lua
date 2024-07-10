local M = {}
-- Execute it if fn
function M.if_func(fn_or_value, ...)
  if type(fn_or_value) == "function" then
    return fn_or_value(...)
  else
    return fn_or_value, ...
  end
end

-- stylua: ignore
-- To table if string
function M.if_table(table_or_string)
  return type(table_or_string) == "table" and table_or_string or { table_or_string }
end

function M.if_true(bool, value1, value2)
  if bool then
    return value1
  else
    return value2
  end
end

function M.if_type(_type, value1, value2) return M.if_true(type(value1) == _type, value1, value2) end

function M.if_false(...)
  local nargs = select("#", ...)

  for i = 1, nargs do
    local v = select(i, ...)

    if v then return v end
  end
  return false
end

return M
