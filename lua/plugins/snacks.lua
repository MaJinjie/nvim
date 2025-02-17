local M = {}

---@diagnostic disable: missing-fields
---@module 'snacks'
return {
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {
    ---@type snacks.picker.Config
    picker = {
      previewers = {
        git = { native = true }, -- 使用delta
      },
      win = {
        input = {
          keys = {
            ["<c-n>"] = { "history_forward", mode = { "i", "n" } },
            ["<c-p>"] = { "history_back", mode = { "i", "n" } },
          },
        },
        list = {
          keys = {
            ["<c-n>"] = { "history_forward", mode = { "i", "n" } },
            ["<c-p>"] = { "history_back", mode = { "i", "n" } },
          },
        },
        preview = {
          wo = {
            cursorcolumn = false,
          },
        },
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
            elseif source:match("lsp") then
              custom = { preset = "bottom" }
            elseif source == "explorer" then
              -- VimEnter前，preview自动打开
              custom = { preview = { enabled = vim.v.vim_did_enter == 0, main = true } }
            elseif vim.list_contains({ "buffers" }, source) then
              custom = { preset = "vscode" }
            end
            return vim.tbl_deep_extend("force", default, custom)
          end,
        }--[[@as snacks.picker.Config]])
      end,
      ---@type table<string, snacks.picker.Config>
      sources = {},
    },
  },
  -- stylua: ignore
  keys = {
    -- find add
    { "<leader>fL", function() Snacks.picker.projects({ title = "Plugins", projects = Snacks.picker.util.rtp(), recent = false }) end, desc = "Find Plugins spec" },
    { "<leader>fl", function() Snacks.picker.files({ title = "Lazy", rtp = true, pattern = "'LazyVim' '" }) end, desc = "Find LazyVim" },
    { "<leader>fz", function() Snacks.picker.zoxide() end, desc = "Zoxide" },
    { "<leader>fG", function() Snacks.picker.git_grep() end, desc = "Grep (git)" },
    { "<leader>fN", function() Snacks.picker.treesitter({ filter = LazyVim.config.kind_filter }) end, desc = "Treesitter Notes" },
    -- find replace
    { "<leader>ff", function() Snacks.picker.files({ cwd = LazyVim.root(), hidden = true }) end, desc = "Find Files (Root Dir)" },
    { "<leader><space>", function () Snacks.picker.files({ cwd = LazyVim.root(), layout = { preset = "vscode" } }) end, desc = "Find Files (Root Dir)" },
    -- grep replace
    { "<leader>/",function() Snacks.picker.grep({ cwd = LazyVim.root() }) end, desc = "Grep (Root Dir)" },
    { "<leader>sg", function() Snacks.picker.grep({ cwd = LazyVim.root(), hidden = true }) end, desc = "Grep (Root Dir)" },
    { "<leader>sc", false }, { "<leader>s:", function() Snacks.picker.command_history() end, desc = "Command History" },
    { "<leader>sm", false }, { "<leader>s'", function() Snacks.picker.marks() end, desc = "Marks" },
    { "<leader>sM", false }, { "<leader>sm", function() Snacks.picker.man() end, desc = "Man Pages" },
    { "<leader>sp", false }, { "<leader>sL", function() Snacks.picker.lazy() end, desc = "Search for Plugin Spec" },

    -- explorer replace
    { "<leader>fe", function() Snacks.explorer({ cwd = LazyVim.root(), hidden = true }) end, desc = "Explorer Snacks (root dir)" },
    { "<leader>fE", function() Snacks.explorer({hidden = true}) end, desc = "Explorer Snacks (cwd)" },
    { "<leader>e", function() Snacks.explorer({ cwd = LazyVim.root() }) end, desc = "Explorer Snacks (root dir)" },
    { "<leader>E", function() Snacks.explorer() end, desc = "Explorer Snacks (cwd)" },
  },
}
