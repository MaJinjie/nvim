local M = {}
local builtin = nil

M.default_opts = {
  none = {},
  fd = {
    layout_config = {
      height = 20,
      width = 75,
    },
    preview = {
      hide_on_startup = true
    },
  },
  rg = {
    layout_strategy = "vertical",
    layout_config = {
      height = 0.9,
      width = 0.7,
      preview_height = 0.5,
    },
    preview = {
      hide_on_startup = false
    },
  }
}
M.optional_opts = {
  path_display = function(relative_path)
    return function(opts, path)
      local tail = require("telescope.utils").path_tail(path)
      local expand
      if relative_path == '~' then
        expand = ':h'
      elseif relative_path == '.' then
        expand = ':h'
      else
        expand = ':p:s?' .. relative_path .. '/??'
      end
      local parent_path = vim.fn.fnamemodify(path, expand)
      return parent_path == '.' and tail or string.format("%s => %s/", tail, parent_path)
    end
  end
}
M.cmd_opts = {
  fd = { "--follow", "-H" },
  rg = { "--no-heading", "--with-filename", "--line-number", "--column", "--smart-case", "--max-columns=80", "--max-columns-preview", "--follow" }
}

M.builtin = function(method, program)
  builtin = builtin or require("telescope.builtin")
  program = program or "none"
  return function(opts)
    opts = opts or {}
    builtin[method](vim.tbl_deep_extend("force", M.default_opts[program], opts))
  end
end

M.custom_command = function(command, args)
  args = args or ""
  return vim.list_extend(vim.split(command .. ' ' .. args, " ", { trimempty = true }), M.cmd_opts[command])
end

return M

-- M.browser_opts = {
--   layout_strategy = "bottom_pane",
--   -- layout_config = {
--   --   height = 25,
--   -- },
--
--   select_buffer = true,
--   hidden = { file_browser = true, folder_browser = true },
--   no_ignore = false,
--   hide_parent_dir = true,
--   prompt_path = true,
--   quiet = true,
--   hijack_netrw = true,
--   use_ui_input = true,
--   depth = 1,
--   -- path = vim.loop.cwd(),
--   -- cwd = vim.loop.cwd(),
--   -- cwd_to_path = true,
-- }
