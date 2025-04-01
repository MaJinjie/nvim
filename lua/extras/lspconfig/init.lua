---@diagnostic disable: inject-field
local M = {}
local utils = require("extras.lspconfig.utils")

---@param default_opts? user.lsp.config.diagnostic
---@param server_opts? user.lsp.config.diagnostic
---@param opts user.lsp.Opts
function M.diagnostic(default_opts, server_opts, opts)
  vim.validate({
    default_opts = { default_opts, "t" },
    server_opts = { server_opts, "t", true },
  })

  if server_opts == nil then
    return
  end

  local ns = vim.lsp.diagnostic.get_namespace(opts.client.id)
  local enabled = server_opts.enabled

  if enabled ~= nil then
    if type(enabled) == "function" then
      enabled = enabled(opts)
    end
    ---@cast enabled boolean
    vim.diagnostic.enable(enabled, { bufnr = opts.bufnr, ns_id = ns })
  end

  -- stylua: ignore
  if vim.iter(server_opts):all(function(k) return k == "enabled" end) then return end

  local before_opts = vim.diagnostic.config(nil, ns)
  if not before_opts or vim.tbl_isempty(before_opts) then
    before_opts = default_opts
  end
  vim.diagnostic.config(User.util.tbl_merge(before_opts, server_opts), ns)
end

---@param default_opts user.lsp.config.keys
---@param server_opts? user.lsp.config.keys
---@param opts user.lsp.Opts
function M.keys(default_opts, server_opts, opts)
  vim.validate({
    default_opts = { default_opts, "t" },
    server_opts = { server_opts, "t", true },
  })

  local Keys = require("lazy.core.handler.keys")
  if not Keys.resolve then
    User.util.error("lazy.core.handler.keys don't have resolve!")
    return
  end

  local keys = Keys.resolve(vim.list_extend(vim.deepcopy(default_opts), server_opts or {}))
  for _, key in pairs(keys) do
    ---@cast key +user.lsp.support
    if utils.support({ has = key.has, cond = key.cond, ft = key.ft }, opts) then
      local key_opts = Keys.opts(key --[[@as LazyKeys]])
      key_opts.has = nil
      key_opts.cond = nil
      key_opts.ft = nil
      key_opts.silent = key_opts.silent ~= false
      key_opts.buffer = opts.bufnr
      ---@cast key_opts vim.keymap.set.Opts
      vim.keymap.set(key.mode or "n", key.lhs, key.rhs, key_opts)
    end
  end
end

---@param default_opts user.lsp.config.hooks
---@param server_opts? user.lsp.config.hooks
---@param opts user.lsp.Opts
function M.hooks(default_opts, server_opts, opts)
  vim.validate({
    default_opts = { default_opts, "t" },
    server_opts = { server_opts, "t", true },
  })

  local hooks = User.util.list_merge(vim.deepcopy(default_opts), server_opts or {})

  if utils.support(hooks, opts) then
    for _, hook in pairs(hooks) do
      if type(hook) == "function" then
        hook(opts)
      elseif type(hook) == "table" and utils.support(hook, opts) then
        for _, f in ipairs(hook) do
          f(opts)
        end
      end
    end
  end
end

return M
