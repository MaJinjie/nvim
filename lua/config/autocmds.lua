local autocmd = vim.api.nvim_create_autocmd
local function augroup(name)
  return vim.api.nvim_create_augroup("_" .. name, { clear = true })
end

if vim.g.neovide then
  autocmd({ "InsertEnter", "InsertLeave" }, {
    group = augroup("ime-input"),
    callback = function(ev)
      if ev.event:match("Leave$") then
        vim.g.neovide_input_ime = false
      else
        vim.g.neovide_input_ime = true
      end
    end,
  })
end

autocmd({ "VimResized" }, {
  group = augroup("resize_splits"),
  command = ":wincmd =",
})

-- go to last loc when opening a buffer
autocmd("BufReadPost", {
  group = augroup("last_position"),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].last_position then
      return
    end
    vim.b[buf].last_position = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
autocmd("BufWritePre", {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- set options for some filetypes
autocmd("FileType", {
  group = augroup("set_options"),
  pattern = { "man", "qf", "checkhealth" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
  end,
})
