local M = {}

function M.feedkeys(keys, mode, escape_ks)
  mode = mode or vim.api.nvim_get_mode().mode
  escape_ks = escape_ks or false
  local termcodes = vim.api.nvim_replace_termcodes(keys, true, false, true)
  vim.api.nvim_feedkeys(termcodes, mode, escape_ks)
end

return M
