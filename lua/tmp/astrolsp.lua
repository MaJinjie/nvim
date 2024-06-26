---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  ---@diagnostic disable: missing-fields
  opts = {
    features = {
      autoformat = true, -- enable or disable auto formatting on start
      codelens = true, -- enable/disable codelens refresh on start
      inlay_hints = true, -- enable/disable inlay hints on start
      semantic_tokens = true, -- enable/disable semantic token highlighting
    },
    formatting = { format_on_save = { enabled = true } },
    config = {},
    flags = {},
    servers = {},
    autocmds = {},
    commands = {},
    handlers = {},
    mappings = {},
    on_attach = nil,
    capabilities = {},
    lsp_handlers = {},
  },
}
