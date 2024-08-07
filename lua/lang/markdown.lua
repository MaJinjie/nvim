return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        markdown = { { "prettierd", "prettier" } },
        ["markdown.mdx"] = { { "prettierd", "prettier" } },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed =
          require("astrocore").list_insert_unique(opts.ensure_installed, { "markdown", "markdown_inline" })
      end
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "marksman" })
    end,
  },
  {
    "jay-babu/mason-null-ls.nvim",
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "prettierd" })
    end,
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = "MarkdownPreviewToggle",
    build = "cd app && yarn install",
    ft = "markdown",
    specs = {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local nmap = require("utils").keymap.set.n
        local g = opts.options.g

        nmap {
          ["<Leader>lm"] = { "<Cmd> MarkdownPreviewToggle <CR>", desc = "[markdown-preview] Toggle markdownPreview" },
        }

        g.mkdp_auto_start = 0
        g.mkdp_auto_close = 0
        g.mkdp_combine_preview = 1
        g.mkdp_refresh_slow = 0

        -- g.mkdp_browser = ""

        -- vim.cmd [[
        --   function OpenMarkdownPreview (url)
        --     " execute "silent ! firefox --new-window " . a:url
        --     execute "silent ! firefox " . a:url
        --   endfunction
        --   let g:mkdp_browserfunc = 'OpenMarkdownPreview'
        -- ]]
      end,
    },
  },
  { "ellisonleao/glow.nvim", cmd = "Glow", opts = { height_ratio = 0.9 } },
}
