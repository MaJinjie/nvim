---@class user.lint
local M = {}

---@param bufnr? number
function M.list_linters_for_buffer(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local lint = require("lint")
  -- Use nvim-lint's logic first:
  -- * checks if linters exist for the full filetype first
  -- * otherwise will split filetype by "." and add all those linters
  -- * this differs from conform.nvim which only uses the first filetype that has a formatter
  local names = lint._resolve_linter_by_ft(vim.bo[bufnr].filetype)

  -- Create a copy of the names table to avoid modifying the original.
  names = vim.list_extend({}, names)

  -- Add fallback linters.
  if #names == 0 then
    vim.list_extend(names, lint.linters_by_ft["_"] or {})
  end

  -- Add global linters.
  vim.list_extend(names, lint.linters_by_ft["*"] or {})

  local ctx
  if #names > 0 then
    ctx = {}
    ctx.bufnr = bufnr
    ctx.filename = vim.api.nvim_buf_get_name(bufnr)
    ctx.dirname = vim.fn.fnamemodify(ctx.filename, ":h")
  end

  names = vim.tbl_filter(function(name)
    local linter = lint.linters[name]
    ---@cast linter +user.lint.Linter

    if not linter then
      User.util.warn("Linter not found: " .. name, { title = "nvim-lint" })
    end
    return linter and not (type(linter) == "table" and linter.condition and not linter.condition(name, ctx))
  end, names)

  return names
end

return M

---@class user.lint.Linter: lint.Linter,{}
---@field prepend_args? string[]
---@field condition? fun(name: string, ctx: user.lint.ctx):boolean

---@class user.lint.ctx
---@field bufnr number
---@field filename string
---@field dirname string
