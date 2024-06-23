---@type LazySpec
return {
  "AstroNvim/astrolsp",
  opts = function(_, opts)
    ---@type AstroLSPOpts
    local local_opts = {
      -- Configuration table of features provided by AstroLSP
      features = {
        autoformat = true, -- enable or disable auto formatting on start
        codelens = true, -- enable/disable codelens refresh on start
        inlay_hints = true, -- enable/disable inlay hints on start
        semantic_tokens = true, -- enable/disable semantic token highlighting
      },
      -- customize lsp formatting options
      formatting = {
        format_on_save = {
          enabled = true, -- enable or disable format on save globally
        },
      },
      -- enable servers that you already have installed without mason
      servers = {
        -- "pyright"
      },
      -- customize language server configuration options passed to `lspconfig`
      ---@diagnostic disable: missing-fields
      config = {
        -- clangd = { capabilities = { offsetEncoding = "utf-8" } },
      },
      -- Configure buffer local auto commands to add when attaching a language server
      autocmds = {},
      -- mappings to be set up on attaching of a language server
      mappings = {
        n = {
          ["<Leader>lr"] = {
            function() return ":IncRename " .. vim.fn.expand "<cword>" end,
            expr = true,
            desc = "Rename current symbol",
            cond = "textDocument/rename",
          },
        },
      },
      -- takes two parameters `client` and `bufnr`  (`:h lspconfig-setup`)
      on_attach = function(client, bufnr) end,
      lsp_handlers = {},
    }
    opts = require("astrocore").extend_tbl(opts, local_opts)

    -- noice
    local noice_opts = require("astrocore").plugin_opts "noice.nvim"
    -- disable the necessary handlers in AstroLSP
    if not opts.lsp_handlers then opts.lsp_handlers = {} end
    if vim.tbl_get(noice_opts, "lsp", "hover", "enabled") ~= false then
      opts.lsp_handlers["textDocument/hover"] = false
    end
    if vim.tbl_get(noice_opts, "lsp", "signature", "enabled") ~= false then
      opts.lsp_handlers["textDocument/signatureHelp"] = false
    end

    return opts
  end,
}
