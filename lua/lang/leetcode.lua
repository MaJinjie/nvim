---@type LazyPluginSpec
return {
  "kawre/leetcode.nvim",
  cmd = "Leet",
  dependencies = {
    { "nvim-telescope/telescope.nvim" },
    { "nvim-lua/plenary.nvim" }, -- required by telescope
    { "MunifTanjim/nui.nvim" },
    { "rcarriga/nvim-notify" },
    { "nvim-tree/nvim-web-devicons" },
  },
  opts = {
    arg = "Leet",
    lang = "rust",
    cn = {
      enabled = true,
      translator = false,
      translate_problems = true,
    },
    injector = {
      ["rust"] = {
        before = {},
        after = "fn main() {}",
      },
    },
  },
}
