---@type LazySpec
return {
  { "max397574/better-escape.nvim", event = "InsertCharPre", opts = { mapping = { "jk", "JK" }, timeout = 300 } },
  { "keaising/im-select.nvim", event = "InsertEnter", opts = {} },
}
