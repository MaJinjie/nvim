---@class user.root
---@overload fun(specs: user.root.Specs): string
local M = setmetatable({}, {
  --- @param specs user.root.Specs
  __call = function(self, specs)
    vim.validate({ specs = { specs, "t" } })

    specs = type(specs[1]) == "table" and specs or { specs }
    for _, spec in ipairs(specs) do
      local root = self.preset[spec.preset](spec.opts)
      if root then
        return root
      end
    end
  end,
})

------------------------------------ Detectors ------------------------------------

M.detectors = {}

function M.detectors.cwd()
  return { vim.uv.cwd() }
end

---@param target number|string
function M.detectors.lsp(target)
  local bufnr = type(target) == "number" and target or 0
  local path = type(target) == "string" and target or M.bufpath(bufnr)
  if not path then
    return {}
  end

  local roots = {} ---@type string[]
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  clients = vim.tbl_filter(function(client)
    return not vim.tbl_contains(vim.g.root_lsp_ignore or {}, client.name)
  end, clients) ---@type vim.lsp.Client[]

  for _, client in pairs(clients) do
    local workspace = client.config.workspace_folders
    for _, ws in pairs(workspace or {}) do
      roots[#roots + 1] = vim.uri_to_fname(ws.uri)
    end
    if client.root_dir then
      roots[#roots + 1] = client.root_dir
    end
  end

  return vim.tbl_filter(function(root)
    return M.is_parentdir(path, root) == true
  end, roots)
end

---@param patterns string[]
---@param target number|string
function M.detectors.pattern(patterns, target)
  local path = type(target) == "string" and target or M.bufpath(target --[[@as number]])

  patterns = type(patterns) == "string" and { patterns } or patterns
  ---@cast patterns string[]

  ---@diagnostic disable-next-line: redefined-local
  local ret = vim.fs.find(function(name, path)
    for _, pattern in ipairs(patterns) do
      if pattern:find("%/", 1, true) and path:match(pattern) or name:match(pattern) then
        return true
      end
    end
    return false
  end, { path = path, upward = true })[1]
  return ret and { vim.fs.dirname(ret) } or {}
end

---@param spec user.root.Spec
---@return user.root.Fn
function M.resolve(spec)
  if M.detectors[spec] then
    return M.detectors[spec]
  elseif type(spec) == "function" then
    return spec
  elseif type(spec) == "table" then
    return function(target)
      return M.detectors.pattern(spec, target)
    end
  else
    error("error!")
  end
end

---@param opts? user.root.Opts|{all?: boolean}
function M.detect(opts)
  opts = opts or {}
  opts.specs = vim.g.root_spec or {}
  opts.target = opts.target or 0

  local ret = {} ---@type user.root.spec[]
  for _, spec in ipairs(opts.specs) do
    local paths = M.resolve(spec)(opts.target)

    paths = User.util.dedup(paths)
    table.sort(User.util.dedup(paths), function(a, b)
      return #a > #b
    end)

    if #paths > 0 then
      ret[#ret + 1] = { spec = spec, paths = paths }
      if not opts.all then
        break
      end
    end
  end
  return ret
end

------------------------------------ Setup ------------------------------------

--- @param opts user.root.Opts
function M.info(opts)
  opts = opts or {}
  opts.specs = opts.specs or vim.g.root_spec

  local roots = M.detect({ specs = opts.specs, target = opts.target, all = true })
  local lines = {} ---@type string[]
  local first = true
  for _, root in ipairs(roots) do
    for _, path in ipairs(root.paths) do
      lines[#lines + 1] = ("- [%s] `%s` **(%s)**"):format(
        first and "x" or " ",
        path,
        type(root.spec) == "table" and table.concat(root.spec--[=[@as string[]]=], ", ") or root.spec
      )
      first = false
    end
  end
  lines[#lines + 1] = "```lua"
  lines[#lines + 1] = "vim.g.root_spec = " .. vim.inspect(opts.specs)
  lines[#lines + 1] = "```"
  User.util.info(lines, { title = "Root" })
  return roots[1] and roots[1].paths[1] or vim.uv.cwd()
end

function M.setup()
  vim.api.nvim_create_user_command("Root", function(args)
    M.info({ target = args.bang and vim.uv.cwd() or 0 })
  end, {
    bang = true,
    desc = "Root Actions",
  })

  vim.api.nvim_create_autocmd({ "LspAttach", "DirChanged", "BufDelete" }, {
    group = vim.api.nvim_create_augroup("user_root_cache", { clear = true }),
    callback = function(event)
      M.cache[event.buf] = nil
    end,
  })
end

------------------------------------ Preset ------------------------------------

--- @class user.root.cache
--- @overload fun(buf: number, key: string, cb?: fun():any)
--- @field [string] string
M.cache = setmetatable({}, {
  __call = function(self, buf, key, cb)
    self[buf] = self[buf] or {}
    if not self[buf][key] and cb then
      self[buf][key] = cb()
    end
    return self[buf][key]
  end,
})

M.preset = {}

--- @param opts { buffer?: boolean, cwd?: boolean }
function M.preset.root(opts)
  local buf = vim.api.nvim_get_current_buf()
  local target = opts.buffer and buf or opts.cwd and assert(vim.uv.cwd()) or nil

  return M.cache(buf, ("root:%s"):format(target), function()
    local ret = M.detect({ target = target })
    return ret[1] and ret[1].paths[1]
  end)
end

--- @param opts user.root.Opts
function M.preset.detect(opts)
  local buf = vim.api.nvim_get_current_buf()
  return M.cache(buf, ("detect:%s"):format(opts.specs), function()
    local ret = M.detect(opts)
    return ret[1] and ret[1].paths[1]
  end)
end

function M.preset.cwd()
  return vim.uv.cwd()
end

--- @param opts { buffer?: boolean, cwd?: boolean }
function M.preset.git(opts)
  local path = M.preset.root(opts) or M.preset.cwd()

  if path == nil then
    return
  end

  return vim.fs.root(path, { ".git" })
end

------------------------------------ Util ------------------------------------

---@param buf number
---@param normalize? boolean
function M.bufpath(buf, normalize)
  vim.validate({ buf = { buf, "n", true } })

  return M.realpath(vim.api.nvim_buf_get_name(buf), normalize)
end

---@param path string
---@param normalize? boolean
function M.realpath(path, normalize)
  vim.validate({ path = { path, "s" }, normalize = { normalize, "b", true } })

  if path == "" then
    return nil
  end
  path = normalize and vim.fs.normalize(path) or path
  return vim.uv.fs_realpath(path) or path
end

---@param buf number|string
---@param dir string
function M.is_parentdir(buf, dir)
  vim.validate({ buf = { buf, { "s", "n" } }, dir = { dir, "s" } })

  local path = type(buf) == "string" and buf or M.bufpath(buf --[[@as number]])
  return path and vim.startswith(path, dir)
end

function M.get() end

return M

---@alias user.root.Fn fun(target: number|string): string[]
---@alias user.root.Spec "lsp"|"cwd"|string[]|user.root.Fn

---@class user.root.Opts
---@field target? number|string
---@field specs? user.root.Spec[]

--- @class user.root._Spec
--- @field preset string
--- @field opts? table

--- @alias user.root.Specs user.root._Spec|user.root._Spec[]

---@class user.root.spec
---@field paths string[]
---@field spec user.root.Spec
