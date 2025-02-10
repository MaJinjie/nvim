---@diagnostic disable: missing-fields
---@module 'snacks'
return {
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {
    win = {
      wo = {
        cursorcolumn = false,
      },
    },
    ---@type snacks.picker.Config
    picker = {
      previewers = {
        -- git = { native = true }, -- 使用delta
      },
      -- 与默认配置进行合并
      config = function(opts)
        return vim.tbl_deep_extend("force", opts, {
          layout = function(source)
            ---@diagnostic disable-next-line: unused-local
            local default = type(opts.layout) == "function" and opts.layout(source) or opts.layout
            ---@cast default snacks.picker.layout.Config

            local custom = {} ---@type snacks.picker.layout.Config
            if source:match("grep") then
              custom = { preset = "bottom", preview = "main" }
            elseif source == "explorer" then
              -- VimEnter前，preview自动打开
              custom = { preview = { enabled = vim.v.vim_did_enter == 0, main = true } }
            end
            return vim.tbl_deep_extend("force", default, custom)
          end,
        }--[[@as snacks.picker.Config]])
      end,
      ---@type table<string, snacks.picker.Config>
      sources = {},
    },
  },
  keys = {
    {
      "<leader>fL",
      function()
        Snacks.picker.projects({ title = "Plugins", projects = Snacks.picker.util.rtp(), recent = false })
        local picker = Snacks.picker.explorer()
      end,
      desc = "Plugins spec",
    },
    {
      "<leader>fl",
      function()
        Snacks.picker.files({ title = "Lazy", rtp = true, pattern = "'LazyVim/ " })
      end,
      desc = "Find for Plugin spec",
    },
    {
      "<leader>fz",
      function()
        Snacks.picker.zoxide()
      end,
      desc = "Zoxide",
    },
    {
      "<leader>fG",
      function()
        Snacks.picker.git_grep()
      end,
      desc = "Grep (git)",
    },
    {
      "<leader>fN",
      function()
        Snacks.picker.treesitter({ filter = require("lazyvim.config")["kind_filter"] })
      end,
      desc = "Treesitter Notes",
    },
  },
}
