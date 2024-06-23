local function iterator(opt_ref, entrys)
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
  if is_nested then
    return function(fields)
      if type(fields) == "string" then fields = { fields } end
      return function(entrys)
        for _, field in ipairs(fields) do
          opt_ref[field] = opt_ref[field] or {}
          iterator(opt_ref[field], entrys)
        end
      end
    end
  else
    return function(entrys) iterator(opt_ref, entrys) end
  end
end
