local M = {}

function M.or_default(opts, ...)
  for _, field in ipairs { ... } do
    opts[field] = opts[field] or {}
    opts = opts[field]
  end
  return opts
end

return M
