return {
  "kawre/leetcode.nvim",
  cmd = "Leet",
  opts = {
    arg = "Leet",
    lang = "cpp",
    cn = { enabled = true, translator = false, translate_problems = false },
    injector = {
      ["rust"] = { before = {}, after = "fn main() {}" },
      ["cpp"] = { before = { "#include <bits/stdc++.h>", "using namespace std;" }, after = "int main() {}" },
    },
    hooks = {
      ["question_enter"] = {
        function()
          local bufnr = vim.api.nvim_get_current_buf()

          for key, value in pairs({
            shiftwidth = 4,
            tabstop = 4,
            autoformat = false,
          }) do
            vim.b[bufnr][key] = value
          end

          vim.diagnostic.config(require("astrocore").diagnostics[0])
        end,
        function()
          require("cmp").setup.buffer({
            sources = {
              { name = "buffer" },
            },
          })
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
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
    "nvim-tree/nvim-web-devicons",
    "nvim-treesitter/nvim-treesitter",
  },
}
