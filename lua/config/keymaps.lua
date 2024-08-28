-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set

map("i", "<C-e>", "<End>", { desc = "Jump to Current line end" })

-- floating terminal
--  stylua: ignore
local lazyterm = function() LazyVim.terminal(nil, { cwd = LazyVim.root() }) end
map("i", "<c-/>", lazyterm, { desc = "Terminal (Root Dir)" })
