-- Finds and lists all of the TODO, HACK, BUG, etc comment
-- in your project and loads them into a browsable list.
-- FIX：需要修复的问题
-- TODO：待办任务
-- HACK：临时解决方案
-- WARN：警告或需要注意的地方
-- PERF：性能优化点
-- NOTE：额外信息或注释
-- TEST：测试相关的内容
return {
  "folke/todo-comments.nvim",
  cmd = { "TodoTrouble", "TodoQuickFix" },
  event = "LazyFile",
  opts = {},
  -- stylua: ignore
  keys = {
    { "]T", function() require("todo-comments").jump_next() end, desc = "Next Todo Comment" },
    { "[T", function() require("todo-comments").jump_prev() end, desc = "Previous Todo Comment" },
    { "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "Todo (Trouble)" },
    { "<leader>xT", "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>", desc = "Todo/Fix/Fixme (Trouble)" },
    { "<leader>qt", "<cmd>TodoQuickFix<cr>", desc = "Todo (QuickFix)" },
    { "<leader>qT", "<cmd>TodoQuickFix keywords=TODO,FIX,FIXME", desc = "Todo/Fix/Fixme (QuickFix)" },
  },
}
