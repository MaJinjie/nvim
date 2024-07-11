---@type LazyPluginSpec
return {
  "kawre/leetcode.nvim",
  cmd = "Leet",
  opts = {
    arg = "Leet",
    lang = "cpp",
    cn = { enabled = true, translator = false, translate_problems = true },
    injector = {
      ["rust"] = { before = {}, after = "fn main() {}" },
      ["cpp"] = { before = { "#include <bits/stdc++.h>", "using namespace std;" }, after = "int main() {}" },
    },
    hooks = {
      ["question_enter"] = {
        function()
          local bufnr = vim.api.nvim_get_current_buf()

          vim.cmd.Leet "desc"
          vim.bo.shiftwidth = 4
          vim.bo.tabstop = 4
          vim.b[bufnr].autoformat = false
        end,
        -- 设置映射键
        function()
          require("astrocore").set_mappings({
            n = {
              ["<LocalLeader>t"] = { "<Cmd> Leet test <CR>", desc = "[leetcode] test" },
              ["<LocalLeader>r"] = { "<Cmd> Leet submit <CR>", desc = "[leetcode] run" },
              ["<LocalLeader>R"] = { "<Cmd> Leet reset <CR>", desc = "[leetcode] reset" },
              ["<LocalLeader>l"] = { "<Cmd> Leet list <CR>", desc = "[leetcode] list" },
              ["<LocalLeader>L"] = { "<Cmd> Leet last_submit <CR>", desc = "[leetcode] last_submit" },
              ["<LocalLeader>q"] = { "<Cmd> Leet exit <CR>", desc = "[leetcode] exit" },
              ["<LocalLeader>c"] = { "<Cmd> Leet console <CR>", desc = "[leetcode] console" },
              ["<LocalLeader>i"] = { "<Cmd> Leet info <CR>", desc = "[leetcode] info" },

              ["<Leader>e"] = { "<Cmd> Leet desc toggle <CR>", desc = "[leetcode] desc toggle" },
            },
          }, { buffer = true })
        end,
      },
    },
  },
  specs = {
    "AstroNvim/astrocore",
    opts = {
      autocmds = {
        leetcode_autostart = {
          {
            event = "VimEnter",
            desc = "Start leetcode.nvim on startup",
            nested = true,
            callback = function()
              if vim.fn.argc() ~= 1 then return end -- return if more than one argument given
              local arg = vim.tbl_get(require("astrocore").plugin_opts "leetcode.nvim", "arg") or "leetcode.nvim"
              if vim.fn.argv()[1] ~= arg then return end -- return if argument doesn't match trigger
              local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
              if #lines > 1 or (#lines == 1 and lines[1]:len() > 0) then return end -- return if buffer is non-empty
              require("leetcode").start(true)
            end,
          },
        },
        leetcode_cmp = {
          {
            event = "BufRead",
            pattern = "*/.local/nvim/leetcode/*",
            callback = function()
              require("cmp").setup.buffer {
                sources = {
                  { name = "buffer" },
                },
              }
            end,
          },
        },
      },
    },
  },
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
    "nvim-tree/nvim-web-devicons",
    {
      "nvim-treesitter/nvim-treesitter",
      opts = function(_, opts)
        if opts.ensure_installed ~= "all" then
          opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "html" })
        end
      end,
    },
  },
}
