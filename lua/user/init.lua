local M = vim._defer_require("user", {
  util = ..., ---@module 'user.util'
  root = ..., ---@module 'user.root'

  keymap = ..., ---@module 'user.keymap'

  format = ..., ---@module 'user.format'

  ui = ..., ---@module 'user.ui'
})

return M
