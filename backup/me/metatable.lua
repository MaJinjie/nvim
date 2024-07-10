local get, set = {}, {}
-- 不必深度拷贝,合并后就是一个新的表
get.merge = {
  __call = function(t, ...)
    vim.tbl_map(function(value) t = vim.tbl_deep_extend("force", t, value) end, { ... })
    return t
  end,
}

get.extend = {
  __add = function(t, v)
    local return_table = vim.deepcopy(t)
    for _, value in ipairs(vim.me.F.if_table(v)) do
      table.insert(return_table, value)
    end
    return return_table
  end,
  __sub = function(t, v)
    local return_table = {}
    for _, value in ipairs(t) do
      if value ~= v then table.insert(return_table, value) end
    end
    return return_table
  end,
}

set.config = function(config)
  return {
    -- __index = function(_, k)
    --   local value = rawget(config, k)
    --   if not value then vim.notify(string.format("%s is not value in telescope config", k), vim.log.levels.ERROR) end
    --   return me.F.if_func(value)
    -- end,
    __call = function(_, ...)
      local value = vim.tbl_get(config, ...)
      if not value then vim.notify("__call is not value in telescope config call", vim.log.levels.INFO) end
      return setmetatable(vim.me.F.if_func(value) or {}, get.merge)
    end,
  }
end

return {
  --- comment
  --- @param metatable string metatable_name
  --- @param ... any data
  --- @return metatable
  set = function(metatable, ...) return set[metatable](...) end,

  get = get,
}
