---@class util.root
local M = setmetatable({}, {
  __call = function(t, ...)
    return t.root(...)
  end,
})

M.root_specs = { "lsp", "git", { "lua" }, "cwd" }
M.detectors = {}
M.cache = {} ---@type table<string, string>

---@return string? root
function M.detectors.pwd()
  return vim.fn.expand("%:p:h")
end

---@return string? root
function M.detectors.cwd()
  return vim.uv.cwd()
end

---@param bufnr number
---@param follow boolean
---@return string? root
function M.detectors.lsp(bufnr, follow)
  local path = M.bufpath(bufnr, follow)

  if not path then
    return
  end

  local roots = {} ---@type string[]
  for _, client in pairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    local workspace = client.config.workspace_folders
    for _, ws in pairs(workspace or {}) do
      roots[#roots + 1] = ws.name
    end
    if client.root_dir then
      roots[#roots + 1] = client.root_dir
    end
  end

  roots = vim.tbl_filter(function(value)
    return path:find(value, 1, true) ~= nil
  end, roots)

  return vim.iter(roots):fold(nil, function(acc, v)
    if acc and #acc > #v then
      return acc
    end
    return v
  end)
end

---@param bufnr number
---@param follow boolean
---@param patterns string[] glob pattern
---@return string
function M.detectors.pattern(bufnr, follow, patterns)
  local path = M.bufpath(bufnr, follow) or assert(vim.uv.cwd())

  patterns = vim
    .iter(patterns)
    :map(function(v)
      return vim.fn.glob2regpat(v)
    end)
    :totable()

  local pattern = vim.fs.find(function(name)
    for _, pattern in ipairs(patterns) do
      return name == pattern or vim.fn.match(name, pattern) ~= -1
    end
    return false
  end, { path = path, upward = true })[1]
  return pattern and vim.fs.dirname(pattern)
end

---@param bufnr number
---@param follow boolean
---@return string?
function M.detectors.git(bufnr, follow)
  local path = vim.fs.dirname(M.bufpath(bufnr, follow)) or assert(vim.uv.cwd())
  return require("util").get_git_root(path)
end

---@param spec util.root.Spec
---@return fun(bufnr:number, follow:boolean):string?
function M.resolve(spec)
  if type(spec) == "table" then
    return function(bufnr, follow)
      return M.detectors.pattern(bufnr, follow, spec)
    end
  elseif type(spec) == "function" then
    return spec
  else
    return M.detectors[spec]
  end
end

---@param opts? util.root.detect.Opts
---@return {spec: util.root.Spec, path: string}[] spec_paths
function M.detect(opts)
  opts = opts or {}

  opts.bufnr = vim.F.if_nil(opts.bufnr, vim.fn.bufnr("%"))
  opts.specs = vim.F.if_nil(opts.specs, M.root_specs)
  opts.follow = vim.F.if_nil(opts.follow, false)
  opts.all = vim.F.if_nil(opts.all, false)

  local spec_paths = {}

  for _, spec in ipairs(opts.specs) do
    local path = M.resolve(spec)(opts.bufnr, opts.follow)

    if path then
      table.insert(spec_paths, { spec = spec, path = path })
    end
    if not opts.all and #spec_paths > 0 then
      break
    end
  end

  return spec_paths
end

---@param bufnr number
---@param follow boolean
---@return string?
function M.bufpath(bufnr, follow)
  local path = vim.uv.fs_realpath(vim.fn.bufname(bufnr))

  if not path then
    return
  end

  if follow or vim.startswith(path, assert(vim.uv.cwd())) then
    return path
  end
end

---@param opts? util.root.detect.Opts
---@return string
function M.root(opts)
  opts = opts or {}

  -- opts.specs 如果没给定，那就是默认，没有记录的必要，都记录为nil
  local cache_key = ("%s:%s:%s"):format(
    opts.bufnr or vim.fn.bufnr("%"),
    vim.inspect(opts.specs),
    opts.follow and 1 or 0
  )

  if not M.cache[cache_key] then
    local spec_paths = M.detect(opts)
    M.cache[cache_key] = spec_paths[1] and spec_paths[1].path
  end

  return M.cache[cache_key]
end

function M.setup()
  vim.api.nvim_create_user_command("UserRoot", function(args)
    local spec_paths =
      M.detect({ bufnr = vim.fn.bufnr(args.args), specs = M.root_specs, follow = args.bang, all = true })
    local lines = {} ---@type string[]
    local first = true

    for _, spec_path in ipairs(spec_paths) do
      local spec, path = spec_path.spec, spec_path.path

      lines[#lines + 1] = ("- [%s] `%s` **(%s)**"):format(
        first and "x" or " ",
        path,
        (function()
          if type(spec) == "table" then
            return table.concat(spec, ",")
          elseif type(spec) == "function" then
            return "function"
          else
            return spec
          end
        end)()
      )
      first = false
    end

    lines[#lines + 1] = "```lua"
    lines[#lines + 1] = "root_specs = " .. vim.inspect(M.root_specs)
    lines[#lines + 1] = "```"
    vim.notify(table.concat(lines), vim.log.levels.INFO, { title = "Display Roots" })
  end, { desc = "Display Roots for the current buffer", bang = true, nargs = "?" })
end

return M

---@class util.root
---@operator call:string
---@overload fun(opts?: util.root.detect.Opts):string

---@class util.root.detect.Opts
---@field bufnr? number default current bufnr
---@field specs? util.root.Spec[] default { "lsp", "git", { "lua" }, "cwd" }
---@field follow? boolean default false
---@field all? boolean default false

---@alias util.root.Spec "lsp"|"git"|"cwd"|"pwd"|string[]|fun(buf:number):string
