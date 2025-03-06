-- Define event
local event = require("lazy.core.handler.event")
local file_events = { "BufReadPost", "BufNewFile", "BufWritePre" }

event.mappings["VeryFile"] = { id = "VeryFile", event = file_events }
event.mappings["User VeryFile"] = event.mappings["VeryFile"]
event.mappings["LazyFile"] = { id = "LazyFile", event = "User", pattern = "LazyFile" }

User.util.on_verylazy(function()
  -- Add LazyFile event
  local trigger = function()
    vim.api.nvim_exec_autocmds("User", { pattern = "LazyFile" })
  end
  if vim.bo.filetype:find("dashboard", 1, true) then
    vim.api.nvim_create_autocmd(file_events, {
      once = true,
      callback = trigger,
    })
  else
    trigger()
  end
end)

require("lazy").setup {
  spec = User.util.safe_require("plugins"),
  local_spec = false, -- load project specific .lazy.lua spec files. They will be added at the end of the spec.
  defaults = {
    lazy = false,
    version = "*", -- always use the latest git commit
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = {
    enabled = false, -- check for plugin updates periodically
    notify = false, -- notify on update
  }, -- automatically check for plugin updates
  change_detection = {
    -- automatically check for config file changes and reload the ui
    enabled = false,
    notify = true, -- get a notification when changes are found
  },
  dev = { path = "~/projects" },
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "editorconfig",
        "gzip",
        -- "man",
        -- "matchit",
        -- "matchparen",
        "netrwPlugin",
        "osc52",
        "rplugin",
        -- "shada",
        -- "spellfile",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
}
