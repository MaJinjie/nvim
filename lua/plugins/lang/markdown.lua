return {
  {
    "williamboman/mason.nvim",
    opts = { ensure_installed = { "marksman", "prettier", "prettierd" } },
  },
  { "neovim/nvim-lspconfig", opts = { servers = { marksman = true } } },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        markdown = function(bufnr)
          return { require("util.lsp").conform_first(bufnr, "prettierd", "prettier"), "injected" }
        end,
      },
    },
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = "MarkdownPreviewToggle",
    keys = { { "<leader>cp", ft = "markdown", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview" } },
    build = function()
      require("lazy").load({ plugins = { "markdown-preview.nvim" } })
      vim.fn["mkdp#util#install"]()
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "norg", "rmd", "org", "Avante" },
    opts = {
      heading = { sign = false },
      code = { sign = false, width = "block", left_pad = 1 },
      file_types = { "markdown", "Avante" },
    },
  },
}
