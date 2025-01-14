local M = {}

---@param client vim.lsp.Client
---@param bufnr integer
--- 1 keymap
--- 2 condition invoke
---@param keys table[]
function M.lsp_keys(client, bufnr, keys)
  local function map(mode, lhs, rhs, opts)
    opts = vim.tbl_extend("force", { buffer = bufnr, silent = true }, opts or {})
    vim.keymap.set(mode, lhs, rhs, opts)
  end
  local function support(methods)
    if type(methods) == "string" then
      return client.supports_method(methods, { bufnr = bufnr })
    end
    for _, method in ipairs(methods) do
      if not support(method) then
        return false
      end
    end
    return true
  end

  for _, key in ipairs(keys) do
    if not (key.has and not support(key.has)) and not (key.cond and not key.cond(client, bufnr)) then
      if #key >= 3 then
        map(unpack(key))
      else
        (key[1] or key.callback)(client, bufnr)
      end
    end
  end
end

---@param bufnr integer
---@param ... string
---@return string
function M.conform_first(bufnr, ...)
  local conform = require("conform")
  for i = 1, select("#", ...) do
    local formatter = select(i, ...)
    if conform.get_formatter_info(formatter, bufnr).available then
      return formatter
    end
  end
  return select(1, ...)
end

return M
