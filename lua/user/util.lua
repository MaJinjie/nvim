---@class user.util: LazyUtilCore
local M = setmetatable({}, { __index = require("lazy.core.util") })

local function can_merge(v)
  return type(v) == "table" and (vim.tbl_isempty(v) or not vim.islist(v))
end

M.tbl_merge = M.merge

---@generic T
---@param ... T
---@return T
function M.list_merge(...)
  local ret = select(1, ...)
  if ret == vim.NIL then
    ret = nil
  end
  for i = 2, select("#", ...) do
    local value = select(i, ...)
    if can_merge(ret) and can_merge(value) then
      for k, v in pairs(value) do
        if type(k) == "number" then
          ret[#ret + 1] = v
        else
          ret[k] = M.tbl_merge(ret[k], v)
        end
      end
    elseif value == vim.NIL then
      ret = nil
    elseif value ~= nil then
      ret = value
    end
  end
  return ret
end

---@generic T
---@param fn T
---@param opts? {ms?:number}
---@return T
function M.debounce(fn, opts)
  local timer = assert(vim.uv.new_timer())
  local ms = opts and opts.ms or 100
  return function()
    timer:start(ms, 0, vim.schedule_wrap(fn))
  end
end

---@param queue (function|string)[]
---@param opts? {all?: boolean}
function M.qcall(queue, opts)
  vim.validate({
    queue = { queue, "t" },
    opts = { opts, "t", true },
  })
  opts = opts or {}

  for _, v in ipairs(queue) do
    -- stylua: ignore
    local f = type(v) == "function" and v or function() vim.cmd(v) end

    if pcall(f) and opts.all ~= true then
      return
    end
  end
end

---@generic R
---@param fn fun(...):R
---@param ... any
---@return fun():R
function M.wrap(fn, ...)
  ---@diagnostic disable-next-line: return-type-mismatch
  return setmetatable({ fn = fn, argv = { ... } }, {
    __call = function(self)
      return self.fn(unpack(self.argv))
    end,
  })
end

---@generic T
---@param list T[]
---@return T[]
function M.dedup(list)
  local ret = {}
  local seen = {}
  for _, v in ipairs(list) do
    if not seen[v] then
      table.insert(ret, v)
      seen[v] = true
    end
  end
  return ret
end

function M.safe_require(module)
  local output = { pcall(require, module) }
  if output[1] then
    return unpack(output, 2)
  end
  M.error(table.concat(output, "\n", 2), { title = "Neovim startup" })
end

---@param name string
function M.get_plugin(name)
  return require("lazy.core.config").spec.plugins[name]
end

---@param plugin string
function M.has_plugin(plugin)
  return M.get_plugin(plugin) ~= nil
end

---@param name string
function M.get_plugin_opts(name)
  local plugin = M.get_plugin(name)
  if not plugin then
    return {}
  end
  local Plugin = require("lazy.core.plugin")
  return Plugin.values(plugin, "opts", false)
end

function M.is_loaded(name)
  local Config = require("lazy.core.config")
  return Config.plugins[name] and Config.plugins[name]._.loaded
end

---@param fn fun()
function M.on_verylazy(fn)
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = vim.schedule_wrap(fn),
    once = true,
  })
end

---@param fn fun()
function M.on_lazyfile(fn)
  vim.api.nvim_create_autocmd("User", {
    pattern = "LazyFile",
    callback = vim.schedule_wrap(fn),
    once = true,
  })
end

---@param name string
---@param fn fun(name:string)
function M.on_lazyload(name, fn)
  fn = vim.schedule_wrap(fn)
  if M.is_loaded(name) then
    fn(name)
  else
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyLoad",
      callback = function(event)
        if event.data == name then
          fn(name)
          return true
        end
      end,
    })
  end
end

---@param on_attach fun(opts: user.lsp.Opts)
---@param name? string
function M.on_lspattach(on_attach, name)
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local bufnr = args.buf ---@type number
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and (not name or client.name == name) then
        vim.schedule_wrap(on_attach)({ client = client, bufnr = bufnr })
      end
    end,
  })
end

---@param ft string|string[]
---@param callback fun(args:vim.api.create_autocmd.callback.args):boolean?
function M.on_filetype(ft, callback)
  vim.api.nvim_create_autocmd("FileType", {
    pattern = ft,
    callback = vim.schedule_wrap(callback),
  })
end

return M
