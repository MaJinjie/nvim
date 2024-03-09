-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.scrolloff = 8
vim.opt.conceallevel = 0
vim.opt.cmdheight = 1
vim.opt.foldlevel = 99
vim.o.swapfile = false
vim.opt.inccommand = "split" -- preview incremental substitute
vim.o.guifont = "Hack Nerd Font,JetBrainsMono Nerd Font:h13"
vim.g.transparency = 0.8

if vim.g.neovide then
  vim.g.neovide_transparency = 0.85
  -- 键入时隐藏鼠标
  vim.g.neovide_hide_mouse_when_typing = true
  -- 和系统主题同步
  vim.g.neovide_theme = "auto"
  -- 设置应用程序的刷新频率
  vim.g.neovide_refresh_rate = 60
  -- 设置不再焦点时的刷新频率
  vim.g.neovide_refresh_rate_idle = 5
  -- false强制始终绘制，这可能和上一个选项相反
  vim.g.neovide_no_idle = true
  -- 未保持的更改时退出需要确认
  vim.g.neovide_confirm_quit = true
  -- 设置应用程序是否占据整个屏幕
  vim.g.neovide_fullscreen = true
  -- 是否记住上一次窗口大小
  vim.g.neovide_remember_window_size = true
  -- 设置光标完成动画所需时间，0表示禁用
  -- vim.g.neovide_cursor_animation_length = 0
  -- 启用抗锯齿
  vim.g.neovide_cursor_antialiasing = true
  -- 如果为false,命令模式和编辑模式的切换 不设置动画
  vim.g.neovide_cursor_animate_command_line = false
end
