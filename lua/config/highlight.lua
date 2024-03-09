local M = {}
function M.multiCursor()
  vim.api.nvim_set_hl(0, "MultiCursor", { fg = "#000000", bg = "#938AA9", default = true })
  vim.api.nvim_set_hl(0, "MultiCursorMain", { fg = "#000000", bg = "#98676A", bold = true, default = true })
end

return M
