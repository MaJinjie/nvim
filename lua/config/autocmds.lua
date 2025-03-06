local autocmd = vim.api.nvim_create_autocmd
local augroup = function(name, clear)
  return vim.api.nvim_create_augroup("user_" .. name, { clear = clear ~= false })
end

-- Check if we need to reload the file when it changed
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- Automatically cd to a unique directory
autocmd("VimEnter", {
  group = augroup("autocd_in_unique_dir"),
  callback = function()
    local first = vim.fn.argv(0) --[[@as string]]
    local stat = first and vim.uv.fs_stat(first)
    if stat and stat.type == "directory" then
      vim.uv.chdir(first)
    end
  end,
})

-- resize splits if window got resized
autocmd({ "VimResized" }, {
  group = augroup("resize_splits"),
  command = "wincmd =",
})

-- go to last loc when opening a buffer
autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
      return
    end
    vim.b[buf].lazyvim_last_loc = true
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

-- close some filetypes with <q>
autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "PlenaryTestPopup",
    "checkhealth",
    "dbout",
    "gitsigns-blame",
    "grug-far",
    "help",
    "lspinfo",
    "neotest-output",
    "neotest-output-panel",
    "neotest-summary",
    "notify",
    "startuptime",
    "qf",
    "query",
    "git",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = "Quit buffer",
      })
    end)
  end,
})

autocmd("FileType", {
  group = augroup("fast_page_turning"),
  pattern = { "help", "man" },
  callback = function(args)
    vim.schedule(function()
      vim.keymap.set("n", "u", "<C-u>", { buffer = args.buf, silent = true, nowait = true, desc = "Half-Page Up" })
      vim.keymap.set("n", "d", "<C-d>", { buffer = args.buf, silent = true, nowait = true, desc = "Half-Page Down" })
    end)
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

-- wrap and check for spell in text filetypes
autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Fix conceallevel for json files
autocmd({ "FileType" }, {
  group = augroup("json_conceal"),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-- In neovide, to only enables IME in input mode and command mode
if vim.g.neovide then
  autocmd({ "InsertEnter", "InsertLeave" }, {
    group = augroup("neovide_ime"),
    callback = function(ev)
      if ev.event:match("Leave$") then
        vim.g.neovide_input_ime = false
      else
        vim.g.neovide_input_ime = true
      end
    end,
  })
end
