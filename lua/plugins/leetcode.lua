return {
  "kawre/leetcode.nvim",
  cmd = "Leet",
  init = function()
    vim.api.nvim_create_autocmd("VimEnter", {
      group = vim.api.nvim_create_augroup("leetcode_start", { clear = true }),
      callback = function()
        if vim.fn.argc(-1) ~= 1 then
          return
        end
        if vim.fn.argv(0) == "leetcode.nvim" then
          require("leetcode").start(true)
        end
      end,
      nested = true,
    })
  end,
  opts = {
    cn = { enabled = true, translator = false, translate_problems = false },
    injector = {
      ["rust"] = { before = {}, after = "fn main() {}" },
      ["cpp"] = { before = { "#include <bits/stdc++.h>", "using namespace std;" }, after = "int main() {}" },
    },
  },
}
