-- Options for an individual notification
-- Fields~
-- {title} `(string)`
-- {icon} `(string)`
-- {timeout} `(number|boolean)` Time to show notification in milliseconds, set to false to disable timeout.
-- {on_open} `(function)` Callback for when window opens, receives window as argument.
-- {on_close} `(function)` Callback for when window closes, receives window as argument.
-- {keep} `(function)` Function to keep the notification window open after timeout, should return boolean.
-- {render} `(function|string)` Function to render a notification buffer.
-- {replace} `(integer|notify.Record)` Notification record or the record `id` field. Replace an existing notification if still open. All arguments not given are inherited from the replaced notification including message and level.
-- {hide_from_history} `(boolean)` Hide this notification from the history
-- {animate} `(boolean)` If false, the window will jump to the timed stage. Intended for use in blocking events (e.g. vim.fn.input)

local M = {}
local g_notifier

local function new(init_opts)
  vim.validate {
    init_opts = { init_opts, "t", true },
  }

  local g_notify, g_levels = vim.notify, vim.log.levels
  local g_opts = init_opts or {}
  local notifier = {}

  function notifier.get(key)
    vim.validate { key = { key, "s", true } }
    if key then
      return g_opts[key]
    else
      return vim.deepcopy(g_opts)
    end
  end

  function notifier.set(opts)
    vim.validate { opts = { opts, "t" } }
    for key, value in pairs(opts) do
      g_opts[key] = value
    end
  end

  function notifier.log(level, message, opts)
    vim.validate {
      level = {
        level,
        function(in_level)
          if type(in_level) == "string" then
            return g_levels[in_level:upper()]
          else
            return vim.tbl_contains(g_levels, in_level)
          end
        end,
        "请查看vim.log.levels",
      },
      message = { message, "s" },
      opts = { opts, "t", true },
    }

    level = type(level) == "string" and g_levels[level:upper()] or level
    opts = opts and vim.tbl_extend("force", g_opts, opts) or g_opts

    g_notify(message, level, opts)
  end

  function notifier.debug(message, opts) notifier.log(g_levels.DEBUG, message, opts) end
  function notifier.trace(message, opts) notifier.log(g_levels.TRACE, message, opts) end
  function notifier.info(message, opts) notifier.log(g_levels.INFO, message, opts) end
  function notifier.warn(message, opts) notifier.log(g_levels.WARN, message, opts) end
  function notifier.error(message, opts) notifier.log(g_levels.ERROR, message, opts) end

  return setmetatable(notifier, {
    __index = function(_, k) error(k .. " 不可访问", 2) end,
    __newindex = function(_, k, _) error(k .. " 不可访问", 2) end,
  })
end

setmetatable(M, {
  __index = function(_, k)
    vim.validate { k = { k, "s" } }
    if type(g_notifier) == "nil" then g_notifier = new() end

    return g_notifier[k]
  end,
  __newindex = function(_, k, _) error(k .. " 不可访问", 2) end,
  __call = function(_, opts)
    vim.validate { opts = { opts, "t", true } }
    return new(opts)
  end,
})

return M
