---@diagnostic disable: missing-fields
local theme = require("config.theme")
local util = require("util")

local _aliases = {
  ["lua_ls"] = "lua-language-server",
}
local function get_package_name(name)
  return _aliases[name] or name
end

return {
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    opts_extend = { "ensure_installed" },
    opts = {},
    ---@param opts MasonSettings | {ensure_installed: table<string|string[], string[]>}
    config = function(_, opts)
      require("mason").setup(opts)

      local mr = require("mason-registry")
      mr:on("package:install:success", function()
        vim.defer_fn(function()
          vim.api.nvim_exec_autocmds("FileType", {
            buffer = vim.api.nvim_get_current_buf(),
            modeline = false,
          })
        end, 100)
      end)

      vim.defer_fn(function()
        mr.refresh(function()
          local ensure_installed = vim.tbl_map(function(name)
            return get_package_name(name)
          end, util.dedup(opts.ensure_installed) or {})
          for _, tool in ipairs(util.dedup(ensure_installed) or {}) do
            local p = mr.get_package(tool)
            if not p:is_installed() then
              p:install()
            end
          end
          require("lazy").load({ plugins = { "nvim-lspconfig", "none-ls.nvim", "nvim-lint", "conform.nvim" } })
          vim.cmd("doautocmd FileType")
        end)
      end, 100)
    end,
  },
  {
    "neovim/nvim-lspconfig",
    lazy = true,
    opts_extend = { "diagnostic", "default" },
    ---@type table<string|"default",lspconfig.Config>
    opts = {
      ---@type vim.diagnostic.Opts>
      diagnostic = {
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 2,
          source = "if_many",
        },
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = theme.icons.diagnostic.ERROR,
            [vim.diagnostic.severity.WARN] = theme.icons.diagnostic.WARN,
            [vim.diagnostic.severity.HINT] = theme.icons.diagnostic.HINT,
            [vim.diagnostic.severity.INFO] = theme.icons.diagnostic.INFO,
          },
        },
      },
      default = {
        capabilities = {
          workspace = {
            fileOperations = {
              didRename = true,
              willRename = true,
            },
          },
        },
        on_attach = function(client, bufnr)
          local function map(mode, lhs, rhs, opts)
            opts = vim.tbl_extend("force", { buffer = bufnr, silent = true }, opts or {})
            vim.keymap.set(mode, lhs, rhs, opts)
          end
          local function support(methods)
            if type(methods) == "string" then
              return client.supports_method(methods, { bufnr = bufnr })
            end
            for _, method in ipairs(methods) do
              if not support(method) then
                return false
              end
            end
            return true
          end
          -- stylua: ignore start
          if support("textDocument/definition") then map("n", "gd", vim.lsp.buf.definition) end
          if support("textDocument/References") then map("n", "gr", vim.lsp.buf.references) end
          if support("textDocument/implementation") then map("n", "gI", vim.lsp.buf.implementation) end
          if support("textDocument/typeDefinition") then map("n", "gy", vim.lsp.buf.type_definition) end
          if support("textDocument/declaration") then map("n", "gD", vim.lsp.buf.declaration) end
          if support("textDocument/hover") then map("n", "K", vim.lsp.buf.hover) end
          if support("textDocument/signatureHelp") then map("n", "gK", vim.lsp.buf.signature_help) end

          if support("textDocument/rename") then map("n", "<leader>cr", vim.lsp.buf.rename) end
          if support("textDocument/codeAction") then map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action) end
					if support("textDocument/inlayHint") then vim.lsp.inlay_hint.enable(true, { bufnr = bufnr }) end
          -- stylua: ignore end

          map("n", "gk", "<cmd>normal! <c-]><cr>")
        end,
      },
    },
    config = function(_, opts)
      local lspconfig = require("lspconfig")

      local diagnostic_opts, default_opts = opts.diagnostic, opts.default

      opts.diagnostic = nil
      opts.default = nil

      vim.diagnostic.config(diagnostic_opts)

      local function server_setup(server, server_opts)
        if type(server_opts) == "boolean" then
          if server_opts then
            lspconfig[server].setup(default_opts)
          end
        elseif type(server_opts) == "table" then
          if server_opts.enabled ~= false then
            lspconfig[server].setup(vim.tbl_deep_extend("keep", server_opts, default_opts))
          end
        else
          server_opts(server, default_opts)
        end
      end
      local mr = require("mason-registry")

      default_opts.capabilities = require("blink-cmp").get_lsp_capabilities(default_opts.capabilities, true)
      for server, server_opts in pairs(opts) do
        local ok, p = pcall(mr.get_package, get_package_name(server))
        if ok then
          if p:is_installed() then
            server_setup(server, server_opts)
          else
            p:install():once("success", function()
              server_setup(server, server_opts)
            end)
          end
        end
      end
    end,
  },
  {
    "stevearc/conform.nvim",
    lazy = true,
    -- event = "BufWritePre",
    -- cmd = { "ConformInfo", "Format" },
    -- keys = { { "<leader>cf", ":Format<CR>", mode = { "n", "v" }, desc = "Format Code", silent = true } },
    init = function()
      vim.keymap.set("n", "<leader>uf", function()
        require("util.keymap").toggle("Auto Format (Global)", {
          get = function()
            return vim.g.autoformat ~= false
          end,
          set = function(state)
            vim.g.autoformat = state
            vim.b.autoformat = nil
          end,
        })
      end)
      vim.keymap.set("n", "<leader>uF", function()
        require("util.keymap").toggle("Auto Format (Buffer)", {
          get = function()
            return vim.F.if_nil(vim.b.autoformat, vim.g.autoformat ~= false)
          end,
          set = function(state)
            vim.b.autoformat = state
          end,
        })
      end)
    end,
    ---@module "conform"
    ---@type conform.setupOpts
    opts = {
      default_format_opts = {
        lsp_format = "fallback",
        timeout_ms = 500,
      },
      format_on_save = function(buf)
        return vim.F.ok_or_nil(vim.F.if_nil(vim.b[buf].autoformat, vim.g.autoformat ~= false), {})
      end,
    },
    config = function(_, opts)
      require("conform").setup(opts)
      vim.api.nvim_create_user_command("Format", function(args)
        local range = nil
        if args.count ~= -1 then
          local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
          range = {
            start = { args.line1, 0 },
            ["end"] = { args.line2, end_line:len() },
          }
        end
        require("conform").format({ async = true, range = range }, function(err)
          if not err then
            local mode = vim.api.nvim_get_mode().mode
            if vim.startswith(string.lower(mode), "v") then
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
            end
          end
        end)
      end, { range = true, desc = "Format Code" })
      vim.keymap.set({ "n", "v" }, "<leader>cf", ":Format<cr>", { desc = "Format Code", silent = true })
    end,
  },
  {
    "mfussenegger/nvim-lint",
    lazy = true,
    opts = {
      -- Event to trigger linters
      events = { "BufWritePost", "BufReadPost", "InsertLeave" },
      linters_by_ft = { ["*"] = {}, ["_"] = {} },
      ---@type table<string, lint.Linter|{condition?:(fun():boolean),prepend_args?:string[]}>
      linters = {},
    },
    config = function(_, opts)
      local lint = require("lint")

      for name, linter in pairs(opts.linters) do
        if type(linter) == "table" and type(lint.linters[name]) == "table" then
          lint.linters[name] = vim.tbl_deep_extend("force", lint.linters[name], linter)
          if type(linter.prepend_args) == "table" then
            lint.linters[name].args = lint.linters[name].args or {}
            vim.list_extend(lint.linters[name].args, linter.prepend_args)
          end
        else
          lint.linters[name] = linter
        end
      end
      lint.linters_by_ft = opts.linters_by_ft

      local function try_lint()
        local names = {}
        vim.list_extend(names, lint._resolve_linter_by_ft(vim.bo.filetype))
        if #names == 0 then
          vim.list_extend(names, lint.linters_by_ft["_"])
        end
        vim.list_extend(names, lint.linters_by_ft["*"])

        names = vim.tbl_filter(function(name)
          local linter = lint.linters[name]
          if not linter then
            vim.notify("Linter not found: " .. name, vim.log.levels.WARN, { title = "nvim-lint" })
          end
          ---@cast linter +{condition?:(fun(ctx?:any):boolean)}
          return linter and not (type(linter) == "table" and linter.condition and not linter.condition())
        end, names)

        if #names > 0 then
          lint.try_lint(names)
        end
      end
      vim.api.nvim_create_autocmd(opts.events, {
        group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
        callback = require("util").debounce(100, try_lint),
      })
    end,
  },
  {
    "nvimtools/none-ls.nvim",
    lazy = true,
    opts = function()
      local null_ls = require("null-ls")
      return {
        sources = {
          -- null_ls.builtins.formatting.stylua,
        },
        ---@param client vim.lsp.Client
        ---@param bufnr integer
        on_attach = function(client, bufnr)
          -- stylua: ignore
          -- if client.supports_method("textDocument/formatting", { bufnr = bufnr }) then
          --        vim.keymap.set("n", "<leader>cf", function () require("conform").format() end)
          -- end
          -- if client.supports_method("textDocument/rangeFormatting", { bufnr = bufnr }) then
          -- 	vim.keymap.set("v", "<leader>cf", function()
          -- 		require("conform").format()
          -- 		-- vim.cmd("normal! ")
          -- 	end)
          -- end
        end,
      }
    end,
  },
}
