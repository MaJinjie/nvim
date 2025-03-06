local M = {}

---@param command string
function M.wrap_group(command)
  local action = command:match("%u%l-$")
  local items = require("bufferline.groups").complete("", "", 1)

  vim.ui.select(items, {
    prompt = ("Select group to %s:"):format(action),
  }, function(choice)
    if choice then
      vim.cmd[command](choice)
    end
  end)
end

return {
  "akinsho/bufferline.nvim",
  event = "LazyFile",
  opts = function()
    return {
      options = {
        close_command = User.keymap.bd,
        right_mouse_command = User.keymap.bd,
        diagnostics = "nvim_lsp",
        always_show_bufferline = false,
        diagnostics_indicator = function(count, level)
          local severity = level:match("error") and "ERROR" or level:match("warn") and "WARN" or nil
          return severity and User.config.icons.diagnostics[severity] .. count or ""
        end,
        custom_filter = function(bufnr, _)
          local bufpath = vim.api.nvim_buf_get_name(bufnr)
          local bufname = vim.fn.fnamemodify(bufpath, ":t")

          return bufname:match("^[%w%_%.%-]*$")
        end,
        offsets = {
          {
            filetype = "snacks_layout_box",
          },
        },
        groups = {
          items = {
            {
              name = "lazy",
              -- icon = "󰒲",
              priority = 1,
              matcher = function(b)
                local lazy_dir = vim.fn.stdpath("data") .. "/lazy/"
                local file_name = vim.api.nvim_buf_get_name(b.id)
                return vim.startswith(file_name, lazy_dir)
              end,
              auto_close = true,
            },
          },
        },
      },
    } --[[@as bufferline.UserConfig ]]
  end,
  -- stylua: ignore
  keys = {
    { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer"},
    { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer"},

    { "<leader>bH", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete Buffers to the Right" },
    { "<leader>bL", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete Buffers to the Left" },
    { "<leader>b;", "<cmd>BufferLinePick<cr>", desc = "Pick a buffer" },

    { "<leader>bg", function() M.wrap_group("BufferLineGroupToggle") end, desc = "Toggle Buffer Group" },
    { "<leader>bG", function() M.wrap_group("BufferLineGroupClose") end, desc = "Close Buffer Group" },

    { "<leader>P", "<cmd>BufferLineTogglePin<cr>", desc = "Un/pin a buffer" },
  },
}
