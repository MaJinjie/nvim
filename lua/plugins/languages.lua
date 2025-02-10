return {
  -- python
  {
    {
      "neovim/nvim-lspconfig",
      opts = {
        servers = {
          basedpyright = {
            settings = {
              basedpyright = {
                analysis = {
                  -- Ignore all files for analysis to exclusively use Ruff for linting
                  ignore = { "*" },
                },
              },
            },
          },
        },
      },
    },
  },
  -- rust
  {},
}
