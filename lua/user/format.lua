---@class user.format
local M = {}

---@param bufnr integer
---@param mode "v"|"V"
---@return table {start={row,col}, end={row,col}} using (1, 0) indexing
local function range_from_selection(bufnr, mode)
  -- [bufnum, lnum, col, off]; both row and column 1-indexed
  local start = vim.fn.getpos("v")
  local end_ = vim.fn.getpos(".")
  local start_row = start[2]
  local start_col = start[3]
  local end_row = end_[2]
  local end_col = end_[3]

  -- A user can start visual selection at the end and move backwards
  -- Normalize the range to start < end
  if start_row == end_row and end_col < start_col then
    end_col, start_col = start_col, end_col
  elseif end_row < start_row then
    start_row, end_row = end_row, start_row
    start_col, end_col = end_col, start_col
  end
  if mode == "V" then
    start_col = 1
    local lines = vim.api.nvim_buf_get_lines(bufnr, end_row - 1, end_row, true)
    end_col = #lines[1]
  end
  return {
    ["start"] = { start_row, start_col - 1 },
    ["end"] = { end_row, end_col - 1 },
  }
end

---Formatexpr
---@param opts? user.format.Opts
function M.formatexpr(opts)
  return require("conform").formatexpr(opts)
end

---Format a buffer
---@param opts? user.format.Opts
---@return boolean True if any formatters were attempted
function M.format(opts)
  opts = opts or {}

  local is_visual = vim.list_contains({ "v", "V", "\22" }, vim.api.nvim_get_mode().mode)
  if not opts.range and is_visual then
    opts.range = range_from_selection(0, "V")
  end

  return require("conform").format(opts, function(err)
    if not err then
      if is_visual then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
      end
    end
  end)
end

---@param opts? {bufnr: number}
function M.info(opts)
  opts = opts or {}

  local bufnr = opts.bufnr == 0 and vim.api.nvim_get_current_buf() or opts.bufnr
  local gaf = vim.g.autoformat == nil or vim.g.autoformat
  local baf = vim.b[bufnr].autoformat
  local enabled = M.is_enabled({ bufnr = bufnr })
  local lines = {
    "# Status",
    ("- [%s] global **%s**"):format(gaf and "x" or " ", gaf and "enabled" or "disabled"),
    ("- [%s] buffer **%s**"):format(enabled and "x" or " ", baf == nil and "inherit" or baf and "enabled" or "disabled"),
  }
  User.util[enabled and "info" or "warn"](table.concat(lines, "\n"), { title = "Format (" .. (enabled and "enabled" or "disabled") .. ")" })
end

---@param enable? boolean
---@param opts? { bufnr: number}
function M.enable(enable, opts)
  if enable == nil then
    enable = true
  end
  if opts then
    local bufnr = opts.bufnr == 0 and vim.api.nvim_get_current_buf() or opts.bufnr
    vim.b[bufnr].autoformat = enable
  else
    vim.g.autoformat = enable
    vim.b.autoformat = nil
  end
end

---@param opts? { bufnr: number}
function M.is_enabled(opts)
  if opts then
    local bufnr = opts.bufnr == 0 and vim.api.nvim_get_current_buf() or opts.bufnr
    if vim.b[bufnr].autoformat ~= nil then
      return vim.b[bufnr].autoformat
    end
  end
  return vim.g.autoformat
end

function M.toggle(buf, opts)
  buf = buf or nil
  return Snacks.toggle.new({
    name = "Auto Format (" .. (buf and "Buffer" or "Global") .. ")",
    get = function()
      return M.is_enabled(buf and { bufnr = 0 })
    end,
    set = function(state)
      M.enable(state, buf and { bufnr = 0 })
      M.info({ bufnr = 0 })
    end,
  }, opts)
end

function M.setup()
  -- Autoformat autocmd
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("user_auto_format", { clear = true }),
    callback = function(event)
      if M.is_enabled({ bufnr = event.buf }) then
        M.format()
      end
    end,
  })

  -- Manual format
  vim.api.nvim_create_user_command("Format", function()
    M.format({ async = true, lsp_format = "fallback" })
  end, { range = true, desc = "Format selection or buffer" })

  -- Register toggle mapping
  User.keymap.toggle["<leader>uf"] = M.toggle
  User.keymap.toggle["<leader>uF"] = User.util.wrap(M.toggle, true)
end

return M

---@alias user.format.Opts conform.FormatOpts
