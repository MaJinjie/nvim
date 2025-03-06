---@class user.root
---@overload fun(...): string
local M = setmetatable({}, {
  __call = function(m, ...)
    return m.get(...)
  end,
})

---@type user.root.Spec[]
M.spec = {
  "lsp",
  { "^.git$", "^lua$" },
  "cwd",
}

---@enum user.root.Follow
M.follow = {
  [1] = "buffer",
  [2] = "cwd",
}

---@enum user.root.Scope
M.scope = {
  [3] = "w",
  [4] = "t",
  [5] = "g",
}

M.detectors = {}

---@param opts {bufnr: number, path?: string}
function M.detectors.cwd(opts)
  local cwd = M.cwd("w")
  local path = opts.path or cwd
  return { M.is_parentdir(cwd, path) and cwd or path }
end

---@param opts {bufnr: number, path?: string}
function M.detectors.lsp(opts)
  local path = opts.path or (M.bufpath(opts.bufnr) or M.cwd("w"))
  if not path then
    return {}
  end
  local roots = {} ---@type string[]
  local clients = vim.lsp.get_clients({ bufnr = opts.bufnr })
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
  return vim
    .iter(roots)
    :filter(function(root)
      return path:find(root, 1, true) == 1
    end)
    :totable()
end

---@param patterns string[]|string
---@param opts {bufnr: number, path?: string}
function M.detectors.pattern(patterns, opts)
  local source = opts.path or (M.bufpath(opts.bufnr) or M.cwd("w"))

  patterns = type(patterns) == "string" and { patterns } or patterns
  ---@cast patterns string[]

  local ret = vim.fs.find(function(name, path)
    for _, pattern in ipairs(patterns) do
      if pattern:find("%/", 1, true) and path:match(pattern) or name:match(pattern) then
        return true
      end
    end
    return false
  end, { path = source, upward = true })[1]
  return ret and { vim.fs.dirname(ret) } or {}
end

---@param bufnr number
function M.bufpath(bufnr)
  return M.realpath(vim.api.nvim_buf_get_name(assert(bufnr)))
end

---@param path? string
---@param normalize? boolean
function M.realpath(path, normalize)
  if path == "" or path == nil then
    return nil
  end
  path = normalize and vim.fs.normalize(path) or path
  return vim.uv.fs_realpath(path) or path
end

---@param spec user.root.Spec
---@return user.root.Fn
function M.resolve(spec)
  if M.detectors[spec] then
    return M.detectors[spec]
  elseif type(spec) == "function" then
    return spec
  end
  return function(opts)
    return M.detectors.pattern(spec, opts)
  end
end

---@param opts? user.root.Opts|{all?: boolean}
function M.detect(opts)
  opts = opts or {}
  opts.spec = opts.spec or type(vim.g.root_spec) == "table" and vim.g.root_spec or M.spec
  opts.bufnr = (opts.bufnr == nil or opts.bufnr == 0) and vim.api.nvim_get_current_buf() or opts.bufnr
  opts.follow = opts.follow or "buffer"

  local args = { bufnr = opts.bufnr } ---@type {bufnr: number, path: string}
  if opts.follow == "cwd" then
    local cwd = M.cwd("t")
    if M.is_parentdir(opts.bufnr, cwd) == false then
      args.path = cwd
    end
  end

  local ret = {} ---@type user.root.spec[]
  for _, spec in ipairs(opts.spec) do
    local paths = M.resolve(spec)(args)
    paths = paths or {}
    paths = type(paths) == "table" and paths or { paths }
    ---@cast paths string[]
    local roots = {} ---@type string[]
    for _, p in ipairs(paths) do
      local pp = M.realpath(p)
      if pp and not vim.tbl_contains(roots, pp) then
        roots[#roots + 1] = pp
      end
    end
    table.sort(roots, function(a, b)
      return #a > #b
    end)
    if #roots > 0 then
      ret[#ret + 1] = { spec = spec, paths = roots }
      if not opts.all then
        break
      end
    end
  end
  return ret
end

---@param follow user.root.Follow
function M.info(follow)
  local spec = type(vim.g.root_spec) == "table" and vim.g.root_spec or M.spec

  local roots = M.detect({ all = true, follow = follow })
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
  lines[#lines + 1] = "vim.g.root_spec = " .. vim.inspect(spec)
  lines[#lines + 1] = "```"
  User.util.info(lines, { title = ("Display Root (%s)"):format(follow) })
  return roots[1] and roots[1].paths[1] or vim.uv.cwd()
end

---@type table<number, string>
M.cache = {}

---@param buf? number
function M.clear_cache(buf)
  if buf then
    for _, follow in ipairs(M.follow) do
      M.cache[("%s:%s"):format(buf, follow)] = nil
    end
  else
    M.cache = {}
  end
end

function M.setup()
  vim.api.nvim_create_user_command("Root", function(args)
    local follow = args.bang and "cwd" or "buffer"
    local complete = args.fargs[1] or "info"

    if complete == "info" then
      M.info(follow)
    elseif complete == "clear" then
      M.clear_cache()
    else
      vim.cmd[complete](M.get({ follow = follow }))
    end
  end, {
    bang = true,
    nargs = "?",
    complete = function()
      return { "info", "clear", "cd", "tcd", "lcd" }
    end,
    desc = "Root Actions",
  })

  vim.api.nvim_create_autocmd({ "LspAttach", "DirChanged" }, {
    group = vim.api.nvim_create_augroup("user_root_cache", { clear = true }),
    callback = function(event)
      M.clear_cache(event.buf)
    end,
  })
end

-- returns the root directory based on:
-- * lsp workspace folders
-- * lsp root_dir
-- * root pattern of filename of the current buffer
-- * root pattern of cwd
---@param opts? user.root.Opts
---@return string
function M.get(opts)
  opts = opts or {}
  opts.bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
  opts.follow = opts.follow or "buffer"

  local key = ("%s:%s"):format(opts.bufnr, opts.follow)
  local ret = M.cache[key]
  if not ret then
    local roots = M.detect(opts)
    ret = roots[1] and roots[1].paths[1] or M.cwd("g")
    M.cache[key] = ret
  end
  return ret
end

---@param opts? {path?: string, count?: number}
---@return string?
function M.git(opts)
  opts = opts or {}

  local source = M.realpath(opts.path, true) or M.get_by_count(opts.count)

  local key = ("%s:git"):format(source)
  local ret = M.cache[key]
  if not ret then
    local output = vim.fn.system(("git -C %s rev-parse --show-toplevel"):format(source))

    ret = vim.v.shell_error == 0 and M.realpath(vim.trim(output), true) or nil
    if ret then
      M.cache[key] = ret
    else
      User.util.warn("No Git repository found!", { title = "Git Root" })
    end
  end
  return ret
end

---@param scope user.root.Scope
---@return string
function M.cwd(scope)
  assert(scope, "The parameter scope is required!")
  return (scope == "g" and vim.fn.getcwd(-1, -1)) or (scope == "t" and vim.fn.getcwd(-1)) or assert(vim.uv.cwd())
end

---@param dir number|string
---@param parentdir string
function M.is_parentdir(dir, parentdir)
  dir = type(dir) == "string" and dir or M.bufpath(dir)
  ---@cast dir string
  return dir and vim.startswith(dir, parentdir)
end

---@param count? number
---@return string? directory
function M.get_by_count(count)
  count = count or vim.v.count1
  return count <= 2 and M.get({ follow = M.follow[count] }) or count <= 5 and M.cwd(M.scope[count]) or nil
end

return M

---@alias user.root.Fn fun(opts: {bufnr: number, path?: string}): string|string[]?
---@alias user.root.Spec "lsp"|"cwd"|string|string[]|user.root.Fn

---@class user.root.Opts
---@field bufnr? number
---@field spec? user.root.Spec[]
---@field follow? user.root.Follow

---@class user.root.spec
---@field paths string[]
---@field spec user.root.Spec
