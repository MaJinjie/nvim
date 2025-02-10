-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

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

local opt = vim.opt

opt.guifont = "CaskaydiaCove Nerd Font,JetBrainsMono Nerd Font,Hack Nerd Font:h15"
opt.cursorcolumn = true
opt.jumpoptions = "stack,view,clean"
opt.listchars:append({ eol = "↲" })
