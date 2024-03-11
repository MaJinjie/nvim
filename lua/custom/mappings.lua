---@type MappingsTable
local M = {}

M.disabled = {
  n = {
    ["<leader>n"] = "",
    ["<leader>rn"] = "",
    ["<leader>b"] = "",
    ["<leader>ch"] = "",
    ["<leader>fm"] = "",
  },
}

local map = vim.api.nvim_set_keymap

map("n", "<leader>rn", "<cmd> set nu! run! <CR>", { desc = "toggle line number" })
map("n", "<leader>m", "<cmd> Format <CR>", { desc = "formatting" })
map("n", "[b", "<cmd> lua require('nvchad.tabufline').tabuflinePrev() <CR>", { desc = "prev tab" })
map("n", "]b", "<cmd> lua require('nvchad.tabufline').tabuflineNext() <CR>", { desc = "next tab" })

return M
