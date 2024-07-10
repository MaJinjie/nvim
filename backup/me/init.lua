vim.me = {
  log = {
    error_mappings = {
      -- 能够确切知道按键的信息，防止覆盖而不自知
      ["error"] = {
        desc = "该键不应该存在，却存在了，我不敢设置。",
        have = false,
        override = false,
        notify = true,
        level = vim.log.levels.WARN,
      },
      ["keep"] = {
        desc = "我不知道该键存不存在，如果存在了，就给报个信。",
        have = false,
        override = true,
        notify = true,
        level = vim.log.levels.INFO,
      },
      ["force"] = {
        desc = "该键应该存在却不存在，估计版本更新了。",
        have = true,
        override = true,
        notify = true,
        level = vim.log.levels.INFO,
      },
    },
  },
}

vim.me.F = require "me.F"
vim.me.metatable = require "me.metatable"
-- vim.me.keymap = require "me.keymap"
vim.me.api = require "me.api"
