-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local highlight = require("config.highlight")
local autocmd = vim.api.nvim_create_autocmd

autocmd({ "ColorScheme" }, {
  callback = function()
    highlight.multiCursor()
  end,
})
