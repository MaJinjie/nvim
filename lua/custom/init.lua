local opt = vim.opt
local g = vim.g
local autocmd = vim.api.nvim_create_autocmd
local augroup = function(name)
  return vim.api.nvim_create_augroup("custom_" .. name, { clear = true })
end
-------------------------------------- globals -----------------------------------------
vim.g.vscode_snippets_path = os.getenv "XDG_CONFIG_HOME" .. "/nvim/snippets"

if g.neovide then
  g.neovide_transparency = 0.85
  -- 键入时隐藏鼠标
  g.neovide_hide_mouse_when_typing = true
  -- 和系统主题同步
  g.neovide_theme = "auto"
  -- 设置应用程序的刷新频率
  g.neovide_refresh_rate = 60
  -- 设置不再焦点时的刷新频率
  g.neovide_refresh_rate_idle = 5
  -- false强制始终绘制，这可能和上一个选项相反
  g.neovide_no_idle = true
  -- 未保持的更改时退出需要确认
  g.neovide_confirm_quit = true
  -- 设置应用程序是否占据整个屏幕
  g.neovide_fullscreen = true
  -- 是否记住上一次窗口大小
  g.neovide_remember_window_size = true
  -- 设置光标完成动画所需时间，0表示禁用
  -- g.neovide_cursor_animation_length = 0
  -- 启用抗锯齿
  g.neovide_cursor_antialiasing = true
  -- 如果为false,命令模式和编辑模式的切换 不设置动画
  g.neovide_cursor_animate_command_line = false
end
-------------------------------------- options ------------------------------------------
opt.relativenumber = true
opt.scrolloff = 8
opt.sidescrolloff = 8 -- Columns of context
opt.timeoutlen = 300
opt.inccommand = "split" -- preview incremental substitute
opt.undolevels = 10000
opt.guifont = "Hack Nerd Font,JetBrainsMono Nerd Font:h13"
opt.swapfile = false

opt.foldcolumn = "1" -- '0' is not bad
opt.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
opt.foldlevelstart = 99
opt.foldenable = true
opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}

-------------------------------------- cmd ------------------------------------------

vim.cmd [[ abbr reutrn return ]]

-------------------------------------- autocmds ------------------------------------------
-- autocmds

-- Highlight on yank
autocmd("TextYankPost", {
  group = augroup "highlight_yank",
  callback = function()
    vim.highlight.on_yank { timeout = 200 }
  end,
})

-- close some filetypes with <q>
autocmd("FileType", {
  group = augroup "close_with_q",
  pattern = {
    "PlenaryTestPopup",
    "help",
    "lspinfo",
    "man",
    "notify",
    "qf",
    "query",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "neotest-output",
    "checkhealth",
    "neotest-summary",
    "neotest-output-panel",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = augroup "auto_create_dir",
  callback = function(event)
    if event.match:match "^%w%w+://" then
      return
    end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- save format
autocmd("BufWritePost", {
  group = augroup "formatter",
  command = ":FormatWrite",
})
