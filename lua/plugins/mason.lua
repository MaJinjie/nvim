return {
  "williamboman/mason.nvim",
  opts = {
    ensure_installed = {
      "shellcheck",

      -- formatter
      "stylua",
      "clang-format",
      "cmakelang",
      "shfmt",

      -- ls
      "yaml-language-server",
      "lua-language-server",
      "clangd",
      "pyright",
      "neocmakelsp",

      -- lint
      "flake8",
      "cmakelint",

      -- dap
      "codelldb",
    },
  },
  -- https://github.com/clangd/clangd/releases/download/17.0.3/clangd-linux-17.0.3.zip
  -- https://github.com/clangd/clangd/releases/17.0.3/clangd-linux-17.0.3.zip
  config = function(_, opts)
    require("mason").setup(opts)
    require("mason").setup({
      github = {
        ---@since 1.0.0
        -- The template URL to use when downloading assets from GitHub.
        -- The placeholders are the following (in order):
        -- 1. The repository (e.g. "rust-lang/rust-analyzer")
        -- 2. The release version (e.g. "v0.3.0")
        -- 3. The asset name (e.g. "rust-analyzer-v0.3.0-x86_64-unknown-linux-gnu.tar.gz")
        download_url_template = "https://github.com/%s/releases/download/%s/%s",
        -- download_url_template = "https://github.com/%s/releases/%s/%s",
      },
    })
  end
}
