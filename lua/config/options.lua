-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- set to `true` to follow the main branch
vim.g.lazyvim_blink_main = true
-- LSP Server to use for Python.
vim.g.lazyvim_python_lsp = "basedpyright"
vim.g.lazyvim_python_ruff = "ruff"
-- LSP Server to use for Rust.
vim.g.lazyvim_rust_diagnostics = "bacon-ls"

if vim.g.neovide then
  vim.o.guifont = "CaskaydiaCove Nerd Font,JetBrainsMono Nerd Font:h10"
  -- 设置窗口显示比例
  vim.g.neovide_scale_factor = 1.0
  -- 设置窗口模糊(macos)
  vim.g.neovide_window_blurred = true
  -- 设置透明度
  vim.g.neovide_transparency = 1
  vim.g.neovide_normal_opacity = 0.8
  -- 键入时隐藏鼠标
  vim.g.neovide_hide_mouse_when_typing = true
  -- neovide 主题色彩 light dark auto
  vim.g.neovide_theme = "auto"
  -- 启动时使用上一次会话的窗口大小
  vim.g.neovide_remember_window_size = true
  -- 命令行和编辑窗口切换的动画
  vim.g.neovide_cursor_animate_command_line = true
  -- 为浮动窗口启用模糊效果
  -- vim.g.neovide_floating_blur = true
end

local opt = vim.opt

opt.cursorcolumn = true
opt.jumpoptions = "stack,view,clean"
opt.listchars:append({ eol = "↲" })
