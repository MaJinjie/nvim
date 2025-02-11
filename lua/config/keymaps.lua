-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set

if vim.g.neovide then
  map("n", "<C-=>", function()
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.1
  end)
  map("n", "<C-->", function()
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.1
  end)
  map("n", "<C-0>", function()
    vim.g.neovide_scale_factor = 1
  end)
end

-- buffers
map("n", "<S-h>", "<cmd>execute 'bprevious' . v:count1<cr>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<cmd>execute 'bnext' . v:count1<cr>", { desc = "Next Buffer" })
map("n", "[b", "<cmd>execute 'bprevious' . v:count1<cr>", { desc = "Prev Buffer" })
map("n", "]b", "<cmd>execute 'bnext' . v:count1<cr>", { desc = "Next Buffer" })
map("n", "<leader>bo", function()
  local tab_buflist = vim.fn.tabpagebuflist()
  Snacks.bufdelete(function(buf)
    return not vim.list_contains(tab_buflist, buf)
  end)
end, { desc = "Delete Other Buffers Except the visual windows" })
map("n", "<leader>bO", function()
  Snacks.bufdelete.other()
end, { desc = "Delete Other Buffers" })

-- tabs
map("n", "<leader><tab>[", "<cmd>execute 'tabprevious' . v:count1<cr>", { desc = "Previous Tab" })
map("n", "<leader><tab>]", "<cmd>execute 'tabnext' . v:count1<cr>", { desc = "Next Tab" })
map("n", "<leader><tab>n", "<cmd>tabnew<cr>", { desc = "New Tab" })
map("n", "<leader><tab><tab>", function()
  if vim.fn.tabpagenr("#") == 0 then
    vim.cmd("tabnew %")
  else
    vim.cmd("tabnext #")
  end
end, { desc = "Switch to Other Tabpage" })
