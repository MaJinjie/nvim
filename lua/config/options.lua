vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Disable Snacks animate
vim.g.snacks_animate = false

-- Enable auto format, used for BufWritePre
vim.g.autoformat = true

-- Enable auto colorize, used for colorizer.nvim
vim.g.autocolorize = false

-- Colorscheme, used to set colorscheme
vim.g.colorscheme = "tokyonight" -- "tokyonight"

-- used for user.dir
-- Root dir detection
-- Each entry can be:
-- * the name of a detector function like `lsp` or `cwd`
-- * a pattern or array of patterns like `.git` or `lua`.
-- * a function with signature `function(buf) -> string|string[]`
-- vim.g.root_spec = { "lsp", { "^.git$", "^lua$" }, "cwd" }

-- used for user.dir
-- Set LSP servers to be ignored when used with `util.root.detectors.lsp`
-- for detecting the LSP root
vim.g.root_lsp_ignore = { "copilot" }

local opt = vim.opt

opt.autowrite = true -- Enable auto write
-- only set clipboard if not in ssh, to make sure the OSC 52
-- integration works automatically. Requires Neovim >= 0.10.0
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- Sync with system clipboard
opt.completeopt = "menu,menuone,noselect"
opt.conceallevel = 2 -- Hide * markup for bold and italic, but not markers with substitutions
opt.confirm = true -- Confirm to save changes before exiting modified buffer
opt.cursorline = true -- Enable highlighting of the current line
opt.cursorcolumn = true -- Enable highlighting of the current column
opt.cmdheight = 0
opt.expandtab = true -- Use spaces instead of tabs
opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}
opt.foldlevel = 99
opt.formatexpr = "v:lua.User.format.formatexpr()"
opt.formatoptions = "jcroqlnt" -- tcqj
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --color=never --vimgrep"
opt.ignorecase = true -- Ignore case
opt.inccommand = "nosplit" -- preview incremental substitute
opt.jumpoptions = "stack,view,clean"
opt.laststatus = 3 -- global statusline
opt.linebreak = true -- Wrap lines at convenient points
opt.list = true -- Show some invisible characters (tabs...
opt.mouse = "a" -- Enable mouse mode
opt.number = true -- Print line number
opt.pumblend = 10 -- Popup blend
opt.pumheight = 10 -- Maximum number of entries in a popup
opt.relativenumber = true -- Relative line numbers
opt.ruler = false -- Disable the default ruler
opt.scrolloff = 4 -- Lines of context
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.shiftround = true -- Round indent
opt.shiftwidth = 2 -- Size of an indent
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.showmode = false -- Dont show mode since we have a statusline
opt.sidescrolloff = 8 -- Columns of context
opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
opt.smartcase = true -- Don't ignore case with capitals
opt.smartindent = true -- Insert indents automatically
opt.spelllang = { "en" }
opt.splitbelow = true -- Put new windows below current
opt.splitkeep = "screen"
opt.splitright = true -- Put new windows right of current
opt.statuscolumn = [[%!v:lua.User.ui.statuscolumn()]]
opt.switchbuf = { "useopen", "uselast" } -- Controls the behavior when switching between buffers.
opt.tabstop = 2 -- Number of spaces tabs count for
opt.termguicolors = true -- True color support
opt.timeoutlen = 300 -- Lower than default (1000) to quickly trigger which-key
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200 -- Save swap file and trigger CursorHold
opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
opt.wildmode = "longest:full,full" -- Command-line completion mode
opt.winminwidth = 5 -- Minimum window width
opt.wrap = false -- Disable line wrap
opt.smoothscroll = true
opt.foldexpr = "v:lua.User.ui.foldexpr()"
opt.foldmethod = "expr"
opt.foldtext = ""

-- neovide
if vim.g.neovide then
  vim.o.guifont = "CaskaydiaCove Nerd Font,JetBrainsMono Nerd Font:h10:#h-none"
  -- 设置窗口显示比例
  vim.g.neovide_scale_factor = 1.0
  vim.g.neovide_initial_scale_factor = vim.g.neovide_scale_factor
  vim.g.neovide_increment_scale_factor = 0.1
  vim.g.neovide_min_scale_factor = 0.7
  vim.g.neovide_max_scale_factor = 2.0
  -- 设置Padding
  vim.g.neovide_padding_top = 10
  vim.g.neovide_padding_bottom = 0
  vim.g.neovide_padding_left = 10
  vim.g.neovide_padding_right = 0
  -- 设置窗口模糊(macos)
  vim.g.neovide_window_blurred = true
  -- 设置透明度
  vim.g.neovide_opacity = 0.75
  vim.g.neovide_normal_opacity = 0.75
  -- 键入时隐藏鼠标
  vim.g.neovide_hide_mouse_when_typing = true
  -- neovide 主题色彩 light dark auto
  vim.g.neovide_theme = "auto"
  -- 启动时使用上一次会话的窗口大小
  vim.g.neovide_remember_window_size = true

  -- animate
  vim.g.neovide_cursor_animate_in_insert_mode = true
  vim.g.neovide_cursor_animate_command_line = true
  vim.g.neovide_cursor_smooth_blink = true
  -- 为浮动窗口启用模糊效果
  -- vim.g.neovide_floating_blur = true
end
