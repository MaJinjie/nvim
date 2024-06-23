---@type LazySpec
return {
  { "folke/flash.nvim", keys = { "f", "F", "t", "T" }, opts = {} },
  { "chrisgrieser/nvim-spider", opts = { consistentOperatorPending = true } },
  { "cbochs/grapple.nvim", cmd = "Grapple", opts = { scope = "git" } },
}
