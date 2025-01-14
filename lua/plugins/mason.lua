---@diagnostic disable: missing-fields
local theme = require("config.theme")
local util = require("util")

local _aliases = {
  ["lua_ls"] = "lua-language-server",
  ["bashls"] = "bash-language-server",
  ["yamlls"] = "yaml-language-server",
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
        end)
      end, 50)
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
        -- stylua: ignore
        keys = {
          { "n", "gd", function() vim.lsp.buf.definition() end, has = "textDocument/definition", {desc = "Goto Definition"} },
          { "n", "gr", function() vim.lsp.buf.references() end, has = "textDocument/references", {desc = "Goto References"} },
          { "n", "gI", function() vim.lsp.buf.implementation() end, has = "textDocument/implementation", {desc = "Goto Implementation"} },
          { "n", "gy", function() vim.lsp.buf.type_definition() end, has = "textDocument/typeDefinition", {desc = "Goto TypeDefinition"} },
          { "n", "gD", function() vim.lsp.buf.declaration() end, has = "textDocument/declaration", {desc = "Goto Declaration"} },
          { "n", "K", function() vim.lsp.buf.hover() end, has = "textDocument/hover", {desc = "Hover"} },
          { "n", "gK", function() vim.lsp.buf.signature_help() end, has = "textDocument/signatureHelp", {desc = "Goto SigntureHelp"} },
          { "n", "<leader>cr", function() vim.lsp.buf.rename() end, has = "textDocument/rename", {desc = "Rename Symbol"} },
          { { "n", "v" }, "<leader>ca", function() vim.lsp.buf.code_action() end, has = "textDocument/codeAction", {desc = "Code Action"} },
          { function(_, bufnr) vim.lsp.inlay_hint.enable(true, { bufnr = bufnr }) end, has = "textDocument/inlayHint" },
        },
        capabilities = {
          workspace = {
            fileOperations = {
              didRename = true,
              willRename = true,
            },
          },
        },
      },
    },
    config = function(_, opts)
      local lspconfig = require("lspconfig")

      local diagnostic_opts, default_opts = opts.diagnostic, opts.default

      opts.diagnostic = nil
      opts.default = nil

      vim.diagnostic.config(diagnostic_opts)

      local default_keys = default_opts.keys
      local default_on_attach = default_opts.on_attach
      local function server_setup(server, server_opts)
        local server_keys, server_on_attach
        if type(server_opts) == "table" then
          server_keys = server_opts.keys
          server_on_attach = server_opts.on_attach
          server_opts.keys = nil
          server_opts.on_attach = nil
        end

        default_opts.on_attach = function(client, bufnr)
          if default_keys or server_keys then
            local keys, dkeys, akeys = {}, default_keys or {}, server_keys or {}

            for k, _ in pairs(akeys) do
              if type(k) == "number" then
                table.insert(keys, akeys[k])
              else
                dkeys[k] = akeys[k]
              end
            end
            for k, _ in pairs(dkeys) do
              if type(k) == "number" or dkeys[k] then
                table.insert(keys, dkeys[k])
              end
            end

            require("util.lsp").lsp_keys(client, bufnr, keys)
          end
          if default_on_attach then
            default_on_attach(client, bufnr)
          end
          if server_on_attach then
            server_on_attach(client, bufnr)
          end
        end

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

      default_opts.keys = nil
      default_opts.on_attach = nil
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
      vim.cmd("doautocmd FileType")
    end,
  },
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
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
  },
  {
    "mfussenegger/nvim-lint",
    event = "BufReadPost",
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
          ---@cast linter +{condition?:(fun():boolean)}
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
  {
    "mfussenegger/nvim-dap",
    dependencies = { "rcarriga/nvim-dap-ui", "theHamsta/nvim-dap-virtual-text" },
    cmd = { "DapNew" },
    opts = {
      ---@type table<string, dap.Adapter|dap.AdapterFactory>
      adapters = {
        gdb = {
          type = "executable",
          command = "gdb",
          args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
        },
        codelldb = {
          type = "executable",
          command = "codelldb",
        },
      },
      ---@type table<string, dap.Configuration[]>
      configurations = {},
    },
    config = function(_, opts)
      local dap = require("dap")

      dap.adapters = vim.tbl_deep_extend("force", dap.adapters or {}, opts.adapters)
      dap.configurations = vim.tbl_deep_extend("force", dap.configurations or {}, opts.configurations)

      require("dap.ext.vscode").json_decode = function(str)
        return vim.json.decode(require("plenary.json").json_strip_comments(str))
      end
    end,
    -- stylua: ignore
    keys = {
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Run/Continue" },
      -- { "<leader>da", function() require("dap").continue({ before = get_args }) end, desc = "Run with Args" },
      { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
      { "<leader>dg", function() require("dap").goto_() end, desc = "Go to Line (No Execute)" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
      { "<leader>dj", function() require("dap").down() end, desc = "Down" },
      { "<leader>dk", function() require("dap").up() end, desc = "Up" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
      { "<leader>do", function() require("dap").step_out() end, desc = "Step Out" },
      { "<leader>dO", function() require("dap").step_over() end, desc = "Step Over" },
      { "<leader>dP", function() require("dap").pause() end, desc = "Pause" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
      { "<leader>ds", function() require("dap").session() end, desc = "Session" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
      { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "nvim-neotest/nvim-nio" },
    -- stylua: ignore
    keys = {
      { "<leader>du", function() require("dapui").toggle({ }) end, desc = "Dap UI" },
      { "<leader>de", function() require("dapui").eval() end, desc = "Eval", mode = {"n", "v"} },
    },
    opts = {},
    config = function(_, opts)
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup(opts)
      -- dap.listeners.before.attach.dapui_config = function()
      -- 	dapui.open()
      -- end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      -- dap.listeners.before.event_terminated.dapui_config = function()
      -- 	dapui.close()
      -- end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end
    end,
  },
  { "theHamsta/nvim-dap-virtual-text", lazy = true },
}
