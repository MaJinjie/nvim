local M = {}

M.support = setmetatable({}, {
  __call = function(self, t, opts)
    vim.validate({ t = { t, "t" }, opts = { opts, "t" } })

    for s, f in pairs(self) do
      if t[s] ~= nil and not f(t[s], opts) then
        return false
      end
    end
    return true
  end,
})

---@param ft string|{[number]: string, exclude?: boolean}|nil
---@param opts user.lsp.Opts
---@return boolean
function M.support.ft(ft, opts)
  if ft == nil then
    return true
  end

  local fts = type(ft) == "table" and ft or { ft } ---@type {[number]: string, exclude?: boolean}
  local exclude = fts.exclude == true
  local filetype = vim.bo[opts.bufnr].filetype

  local ok = false
  for _, f in ipairs(fts) do
    if f == filetype then
      ok = true
      break
    end
  end
  return exclude ~= ok
end

---@param method string|string[]|nil
---@param opts user.lsp.Opts
---@return boolean
function M.support.has(method, opts)
  if method == nil then
    return true
  end
  local methods = type(method) == "table" and method or { method }
  ---@cast methods string[]
  for _, m in ipairs(methods) do
    if not opts.client.supports_method(m, { bufnr = opts.bufnr }) then
      return false
    end
  end
  return true
end

---@param fn boolean|fun(opts: user.lsp.Opts)|nil
---@param opts user.lsp.Opts
---@return boolean
function M.support.cond(fn, opts)
  if type(fn) == "function" then
    return fn(opts) ~= false
  else
    return fn ~= false
  end
end

return M
