local M = setmetatable({}, { __index = require("heirline.conditions") })

function M.is_git_repo()
  if vim.b.gitsigns_head ~= nil then
    return vim.b.gitsigns_head ~= ""
  end

  vim.fn.system(("git -C %s rev-parse --is-inside-work-tree"):format(vim.fn.expand("%:h")))
  return vim.v.shell_error == 0
end

function M.is_recording_macro()
  return vim.fn.reg_recording() ~= ""
end

function M.has_diff()
  return vim.b.gitsigns_status and vim.b.gitsigns_status ~= ""
end

function M.is_file()
  return vim.bo.buftype == ""
end

function M.file_is_modified()
  return vim.bo.modified
end

function M.file_is_readonly()
  return not vim.bo.modifiable or vim.bo.readonly
end

---@param name string
function M.is_available(name)
  return User.util.has_plugin(name)
end

---@alias _.heirline.source.Provider "lsp"|"formatter"|"linter"
---@param opts {provider: _.heirline.source.Provider[]}
---@return boolean has
---@return table<_.heirline.source.Provider,string[]>
function M.has_sources(opts)
  local fns = {}
  fns.lsp_attached = function()
    return vim.tbl_map(function(client)
      return client.name
    end, vim.lsp.get_clients({ bufnr = 0 }))
  end
  fns.formatter_attached = function()
    if not M.is_available("conform.nvim") then
      return {}
    end
    return require("conform").list_formatters_for_buffer(0)
  end
  fns.linter_attached = function()
    if not M.is_available("nvim-lint") then
      return {}
    end
    return require("extras.lint").list_linters_for_buffer(0)
  end

  local has, ret = false, {}
  for _, p in ipairs(opts.provider) do
    local names = fns[p .. "_attached"]()
    ret[p] = names
    if #names > 0 then
      has = true
    end
  end
  return has, ret
end

---@param opts {severity: vim.diagnostic.Severity[]}
---@return boolean has
---@return table<vim.diagnostic.Severity, integer>
function M.has_diagnostics(opts)
  if not vim.diagnostic.is_enabled({ bufnr = 0 }) then
    return false, {}
  end
  local ret = vim.diagnostic.count(0, { severity = opts.severity })
  return next(ret) ~= nil, ret
end

return M
