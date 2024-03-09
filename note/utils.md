# api
3. vim.api.nvim_buf_get_name(0) 0 获取buffer完整路径
4. vim.api.nvim_buf_get_option 获取buffer的某一个选项


# loop 
cwd() 
fs_ 一堆文件操作


# fn 

## expand 
vim.print(vim.fn.expand('%'))
vim.print(vim.fn.expand('%:p'))
vim.print(vim.fn.expand('%:h'))
vim.print(vim.fn.expand('%:t'))
vim.print(vim.fn.expand('%:r'))
vim.print(vim.fn.expand('%:e'))
vim.print(vim.fn.expand('%:p:h'))
vim.print(vim.fn.expand('%:p:t'))
vim.print(vim.fn.expand('%:p:r'))
vim.print(vim.fn.expand('%:p:e'))


# vim 
1. vim.tbl_deep_extend vim.tbl_extend
2. vim.split 字符串 -> table 
3. tbl_filter -> 使用函数过滤表 return true 的 条目
4. tbl_map(f, tb) 
