return {
  "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
  event = "LspAttach",
  enabled = false,
  dependencies = {
    {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          n = {
            ["<Leader>uD"] = {
              function()
                local toggle = require("lsp_lines").toggle()
                vim.notify("Toggle virtual diagnostic lines " .. toggle and "on" or "off", vim.log.levels.INFO)
              end,
              desc = "Toggle virtual diagnostic lines",
            },
          },
        },
        diagnostics = {
          virtual_text = false,
          virtual_lines = {
            only_current_line = true,
          },
        },
      },
    },
  },
  opts = {},
}
