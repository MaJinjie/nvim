---@diagnostic disable: missing-fields
return {
  {
    "folke/snacks.nvim",
    -- stylua: ignore
    keys = {
      { "<leader>gg", function() Snacks.lazygit({cwd = User.root({ preset = "root", opts = { buffer = true } })}) end, desc = "LazyGit (Root)" },
      { "<leader>gG", function() Snacks.lazygit({cwd = User.root({ preset = "cwd" })}) end, desc = "LazyGit (Cwd)" },
      { "<leader>gx", function() Snacks.gitbrowse() end, mode = {"n", "v"}, desc = "Git Browse (open)" }
    },
  },
}
