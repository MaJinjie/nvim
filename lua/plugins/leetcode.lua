return {
  "kawre/leetcode.nvim",
  lazy = "leetcode" ~= vim.fn.argv()[1],
  cmd = "Leet",
  opts = {
    arg = "leetcode",
    lang = "typescript",
    cn = { enabled = true, translator = false, translate_problems = false },
    injector = {
      ["rust"] = { before = {}, after = "fn main() {}" },
      ["cpp"] = { before = { "#include <bits/stdc++.h>", "using namespace std;" }, after = "int main() {}" },
    },
    hooks = {
      ["question_enter"] = {
        -- function()
        --   local bufnr = vim.api.nvim_get_current_buf()
        --
        --   for key, value in pairs({
        --     shiftwidth = 4,
        --     tabstop = 4,
        --     autoformat = false,
        --   }) do
        --     vim.b[bufnr][key] = value
        --   end
        --
        --   vim.diagnostic.config(require("astrocore").diagnostics[0])
        -- end,
        -- function()
        --   require("cmp").setup.buffer({
        --     sources = {
        --       { name = "buffer" },
        --     },
        --   })
        -- end,
        -- 设置映射键
        function()
          local map = vim.keymap.set

          map("n", "<localleader>t", "<cmd> Leet test <cr>", { desc = "leetcode test", buffer = true })
          map("n", "<localleader>r", "<cmd> Leet submit <cr>", { desc = "leetcode submit", buffer = true })
          map("n", "<localleader>R", "<cmd> Leet reset <cr>", { desc = "leetcode reset", buffer = true })
          map("n", "<localleader>l", "<cmd> Leet list <cr>", { desc = "leetcode list", buffer = true })
          map("n", "<localleader>L", "<cmd> Leet last_submit <cr>", { desc = "leetcode last_submit", buffer = true })
          map("n", "<localleader>q", "<cmd> Leet exit <cr>", { desc = "leetcode exit", buffer = true })
          map("n", "<localleader>c", "<cmd> Leet console <cr>", { desc = "leetcode console", buffer = true })
          map("n", "<localleader>i", "<cmd> Leet info <cr>", { desc = "leetcode info", buffer = true })
          map("n", "<localleader>e", "<cmd> Leet desc toggle <cr>", { desc = "leetcode desc toggle", buffer = true })
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
