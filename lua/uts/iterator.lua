local function iterator(opt_ref, entrys)
  assert(type(opt_ref) == "table", "opt_ref must a table")
  for key, value in pairs(entrys) do
    if type(key) == "number" then
      table.insert(opt_ref, value)
    else
      opt_ref[key] = value
    end
  end
end

return function(opt_ref, is_nested)
  opt_ref = opt_ref or {}
  assert(type(opt_ref) == "table", "opt_ref must a table")
  if is_nested ~= nil then
    if is_nested then
      return function(behavior)
        return function(entrys)
          for key, _ in pairs(entrys) do
            if type(entrys[key]) ~= "table" or type(opt_ref[key]) ~= "table" then
              opt_ref[key] = entrys[key]
            else
              opt_ref[key] = vim.tbl_deep_extend(behavior, opt_ref[key], entrys[key])
            end
          end
        end
      end
    else
      return function(fields)
        if type(fields) == "string" then fields = { fields } end
        return function(entrys)
          for _, field in ipairs(fields) do
            opt_ref[field] = opt_ref[field] or {}
            iterator(opt_ref[field], entrys)
          end
        end
      end
    end
  else
    return function(entrys) iterator(opt_ref, entrys) end
  end
end
