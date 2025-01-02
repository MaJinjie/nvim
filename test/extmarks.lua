local extmarks = vim.api.nvim_buf_get_extmarks(0, -1, 0, -1, { details = true, type = "sign" })
local d
vim.print(extmarks)
local a = 11
