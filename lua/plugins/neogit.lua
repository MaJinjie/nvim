return {
  "NeogitOrg/neogit",
  cmd = "Neogit",
  opts = {},
  -- stylua: ignore
  keys = {
    { "<leader>gG", function() require("neogit").open({cwd = User.root.git()}) end, desc = "Neogit" },
  },
}
