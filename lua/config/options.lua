-- vim.g
vim.g.mapleader = ";"
vim.g.maplocalleader = ","
vim.g.langleader = ",,"

vim.g.file_explorer = "oil"

if vim.g.neovide then
  vim.g.neovide_scale_factor = 0.75
  vim.g.neovide_padding_top = 5
  vim.g.neovide_padding_bottom = 0
  vim.g.neovide_padding_right = 0
  vim.g.neovide_padding_left = 0
  vim.g.neovide_transparency = 0.8
  vim.g.neovide_window_blurred = true
  vim.g.neovide_hide_mouse_when_typing = true
  -- vim.g.neovide_flatten_floating_zindex = "20"
  -- vim.g.neovide_floating_shadow = false
  vim.g.neovide_remember_window_size = true
end

-- vim.o
vim.o.guifont = "CaskaydiaCove Nerd Font,JetBrainsMono Nerd Font,Hack Nerd Font:h15"
vim.o.background = "dark"
vim.o.clipboard = "unnamedplus"
vim.o.termguicolors = true
vim.o.timeoutlen = 300
vim.o.virtualedit = "block"
vim.o.autowrite = true
vim.o.confirm = true
vim.o.conceallevel = 2
vim.o.sessionoptions = "buffers,curdir,tabpages,winsize,help,globals,skiprtp,folds"
vim.o.mouse = "a"
vim.o.shortmess = "ltToOCFIcC"
vim.o.number = true
vim.o.relativenumber = true
vim.o.jumpoptions = "stack,view,clean"
vim.o.cmdheight = 0

-- ui
vim.o.cursorline = true
vim.o.colorcolumn = "80"
vim.o.signcolumn = "yes"
vim.o.laststatus = 3
vim.o.statuscolumn = [[%{%v:lua.require'heirline'.eval_statuscolumn()%}]]

-- window
vim.o.winwidth = 5
vim.o.winminwidth = 1
vim.o.winminheight = 1

-- wrap
vim.o.linebreak = true
vim.o.wrap = false

-- float windown
vim.o.winblend = 20

-- scroll
vim.o.scrolloff = 4
vim.o.sidescrolloff = 8
vim.o.smoothscroll = true

-- pop-windown
vim.o.pumblend = 10
vim.o.pumheight = 10

-- ident
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.expandtab = true
vim.o.shiftround = true
vim.o.smartindent = true
vim.o.smarttab = true

-- split
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.splitkeep = "screen"

-- undo
vim.o.undofile = true
vim.o.undolevels = 1000

-- swapfile
vim.o.swapfile = false
vim.o.updatetime = 200

-- complete
vim.o.completeopt = "menu,menuone,noselect"
vim.o.wildmode = "longest:full,full"

-- format
-- vim.o.formatexpr = [[v:lua.require'conform'.formatexpr()]]
-- vim.o.formatoptions = "jcroqlnt"

-- :grep
vim.o.grepprg = "rg --vimgrep --color=never"
vim.o.grepformat = "%f:%l:%c:%m"

-- search
vim.o.ignorecase = true
vim.o.smartcase = true

-- fold
vim.o.foldlevel = 99
vim.o.foldmethod = "expr"
vim.o.foldexpr = [[v:lua.vim.treesitter.foldexpr()]]
vim.o.foldtext = ""

-- listchars
vim.o.list = true
vim.o.listchars = [[tab:│ ,extends:…,precedes:…,nbsp:␣,eol:↲]]
vim.o.fillchars = [[foldopen:,foldclose:,fold:·,foldsep: ,diff:╱]]
