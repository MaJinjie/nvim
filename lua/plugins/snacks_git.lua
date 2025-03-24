---@diagnostic disable: missing-fields
return {
  {
    "folke/snacks.nvim",
    -- stylua: ignore
    keys = {
      { "<leader>gg", function() Snacks.lazygit({ cwd = User.root({ preset = "git", opts = { buffer = true } }) }) end, desc = "Lazygit" },
      { "<leader>gx", function() Snacks.gitbrowse() end, mode = {"n", "v"}, desc = "Git Browse (open)" }
    },
  },
}
