return {
  "neovim/nvim-lspconfig",
  event = "VeryFile",
  ---@type table<string, user.lsp.Config>
  opts = {
    ["*"] = {
      diagnostic = {
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = function(diagnostic)
            local icons = User.config.icons.diagnostics
            return icons[diagnostic.severity] or "●"
          end,
        },
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = User.config.icons.diagnostics.ERROR,
            [vim.diagnostic.severity.WARN] = User.config.icons.diagnostics.WARN,
            [vim.diagnostic.severity.HINT] = User.config.icons.diagnostics.HINT,
            [vim.diagnostic.severity.INFO] = User.config.icons.diagnostics.INFO,
          },
        },
      },
      -- stylua: ignore
      keys = {
        { "gd", function() vim.lsp.buf.definition() end, desc = "Goto Definition", has = "textDocument/definition" },
        { "gr", function() vim.lsp.buf.references() end, desc = "Goto References", has = "textDocument/references" },
        { "gI", function() vim.lsp.buf.implementation() end, desc = "Goto Implementation", has = "textDocument/implementation" },
        { "gy", function() vim.lsp.buf.type_definition() end, desc = "Goto TypeDefinition", has = "textDocument/typeDefinition" },
        { "gD", function() vim.lsp.buf.declaration() end, desc = "Goto Declaration", has = "textDocument/declaration" },
        { "K", function() vim.lsp.buf.hover() end, desc = "Hover", "textDocument/hover" },
        { "gK", function() vim.lsp.buf.signature_help() end, desc = "Goto SignatureHelp", has = "textDocument/signatureHelp" },
        { "<c-k>", function() return vim.lsp.buf.signature_help() end, mode = "i", desc = "Signature Help", has = "textDocument/signatureHelp" },
        { "<leader>cr", function() vim.lsp.buf.rename() end, desc = "Rename Symbol", has = "textDocument/rename" },
        { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File", has = { "workspace/didRenameFiles", "workspace/willRenameFiles" } },
        { "<leader>ca", function() vim.lsp.buf.code_action() end, mode = { "n", "v" }, desc = "Code Action", has = "textDocument/codeAction" },
        { "<leader>cc", function() vim.lsp.codelens.run() end, desc = "Run Codelens", mode = { "n", "v" }, has = "codeLens" },
        { "<leader>cC", function() vim.lsp.codelens.refresh() end, desc = "Refresh & Display Codelens", has = "codeLens" },
        { "]]", function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference", has = "textDocument/documentHighlight", cond = function() return Snacks.words.is_enabled() end },
        { "[[", function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference", has = "textDocument/documentHighlight", cond = function() return Snacks.words.is_enabled() end },
      },
      hooks = {
        inlay_hint = {
          function(opts)
            vim.lsp.inlay_hint.enable(true, { bufnr = opts.bufnr })
          end,
          has = "textDocument/inlayHint",
        },
        codelens = {
          function(opts)
            vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
              buffer = opts.bufnr,
              callback = User.util.debounce(function()
                vim.lsp.codelens.refresh({ bufnr = opts.bufnr })
              end),
            })
          end,
          has = "textDocument/codeLens",
          cond = false,
        },
      },
      opts = {
        -- add any global capabilities here
        capabilities = {
          workspace = {
            fileOperations = { didRename = true, willRename = true },
          },
        },
      },
    },
    -- lua
    lua_ls = {
      opts = {
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            codeLens = { enable = true },
            doc = { privateName = { "^_" } },
            completion = { callSnippet = "Replace" },
            format = { enable = false },
            diagnostics = { enable = true },
            hint = {
              enable = true,
              paramType = true,
              paramName = "Disable",
              semicolon = "Disable",
              arrayIndex = "Disable",
            },
          },
        },
      },
    },
    -- toml
    taplo = {},
    -- yaml
    yamlls = {
      opts = {
        -- Have to add this for yamlls to understand that we support line folding
        capabilities = {
          textDocument = {
            foldingRange = {
              dynamicRegistration = false,
              lineFoldingOnly = true,
            },
          },
        },
        -- lazy-load schemastore when needed
        on_new_config = function(new_config)
          new_config.settings.yaml.schemas =
            vim.tbl_deep_extend("force", new_config.settings.yaml.schemas or {}, require("schemastore").yaml.schemas())
        end,
        settings = {
          redhat = { telemetry = { enabled = false } },
          yaml = {
            keyOrdering = false,
            format = {
              enable = true,
            },
            validate = true,
            schemaStore = {
              -- Must disable built-in schemaStore support to use
              -- schemas from SchemaStore.nvim plugin
              enable = false,
              -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
              url = "",
            },
          },
        },
      },
    },
    -- json
    jsonls = {
      opts = {
        -- lazy-load schemastore when needed
        on_new_config = function(new_config)
          new_config.settings.json.schemas = new_config.settings.json.schemas or {}
          vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
        end,
        settings = {
          json = {
            format = {
              enable = true,
            },
            validate = { enable = true },
          },
        },
      },
    },
    -- markdown
    marksman = { enabled = true },
    -- python
    basedpyright = {
      diagnostic = { enabled = false },
      opts = {
        handlers = {
          ["textDocument/publishDiagnostics"] = function() end,
        },
      },
    },
    ruff = {
      hooks = {
        function(opts)
          local client = opts.client
          client.server_capabilities.hoverProvider = false
        end,
      },
    },
    bashls = {},
    clangd = {},
  },
  keys = {
    { "<leader>ci", "<cmd>LspInfo<cr>", desc = "Lsp Info" },
  },
  ---@param servers table<string, user.lsp.Config>
  config = function(_, servers)
    User.util.on_lspattach(function(opts)
      local attach = require("extras.lspconfig")

      local default, server = servers["*"], servers[opts.client.name]

      attach.diagnostic(default.diagnostic, server.diagnostic, opts)
      attach.keys(default.keys, server.keys, opts)
      attach.hooks(default.hooks, server.hooks, opts)
    end)

    local default = servers["*"]
    -- 先设置全局的诊断信息
    vim.diagnostic.config(default.diagnostic)

    default.opts.capabilities = require("blink-cmp").get_lsp_capabilities(default.opts.capabilities, true)
    ---@param name string
    ---@param server user.lsp.Config
    local function setup(name, server)
      local server_opts = vim.tbl_deep_extend("force", vim.deepcopy(default.opts), server.opts or {})
      ---@cast server_opts -nil

      if server.setup then
        server.setup(name, server_opts)
      elseif default.setup then
        default.setup(name, server_opts)
      else
        require("lspconfig")[name].setup(server_opts)
      end
    end

    for name, server in pairs(servers) do
      if name ~= "*" and server.enabled ~= false then
        setup(name, server)
      end
    end
  end,
}
