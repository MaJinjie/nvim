return {
  "NeogitOrg/neogit",
  cmd = "Neogit",
  opts = {},
  -- stylua: ignore
  keys = {
    { "<leader>gn", function() require("neogit").open({cwd = User.root({ preset = "root", opts = { buffer = true } })}) end, desc = "Neogit (Root)" },
    { "<leader>gN", function() require("neogit").open({cwd = User.root({ preset = "cwd" })}) end, desc = "Neogit (Cwd)" },
  },
}
