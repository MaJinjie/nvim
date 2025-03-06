local M = {}

---@param bufnr integer
---@param ... string
---@return string
function M.first(bufnr, ...)
  local conform = require("conform")
  for i = 1, select("#", ...) do
    local formatter = select(i, ...)
    if conform.get_formatter_info(formatter, bufnr).available then
      return formatter
    end
  end
  return select(1, ...)
end

return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  cmd = "ConformInfo",
  ---@module "conform"
  ---@type conform.setupOpts
  opts = {
    default_format_opts = { lsp_format = "fallback", timeout_ms = 500 },
    formatters_by_ft = {
      lua = { "stylua" },
      toml = { "taplo" },
      yaml = { "yamlfix", "yamlfmt" },
      sh = { "shfmt" },
      markdown = { "prettierd", "prettier", stop_after_first = true },
      python = { lsp_format = "prefer" },
    },
    formatters = {
      ["markdownlint-cli2"] = {
        condition = function(config, ctx)
          local ns = require("lint").get_namespace(config.command --[[@as string]])
          return #vim.diagnostic.get(ctx.buf, { namespace = ns }) > 0
        end,
      },
    },
  },
  -- stylua: ignore
  keys = {
    { "<leader>cf", function() User.format.format() end, mode = { "n", "v" }, desc = "Format" },
    { "<leader>cF", function() User.format.format({ formatters = { "injected" }, timeout_ms = 3000 }) end, mode = { "n", "v" }, desc = "Format Injected Langs" },
  },
}
