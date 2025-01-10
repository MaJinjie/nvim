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
					require("lazy").load({ plugins = { "nvim-lspconfig", "none-ls.nvim" } })
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
		"nvimtools/none-ls.nvim",
		lazy = true,
		opts = function()
			local null_ls = require("null-ls")
			return {
				sources = {
					null_ls.builtins.formatting.stylua,
				},
				---@param client vim.lsp.Client
				---@param bufnr integer
				on_attach = function(client, bufnr)
          -- stylua: ignore
					if client.supports_method("textDocument/formatting", { bufnr = bufnr }) then
						vim.api.nvim_create_autocmd("BufWritePre", {
							group = vim.api.nvim_create_augroup("null-ls-formatting", { clear = true }),
							buffer = bufnr,
							callback = function() vim.lsp.buf.format({ name = client.name, bufnr = bufnr }) end,
						})
            vim.keymap.set("n", "<leader>cf", function () vim.lsp.buf.format({bufnr = bufnr, name = client.name}) end)
					end
					if client.supports_method("textDocument/rangeFormatting", { bufnr = bufnr }) then
						vim.keymap.set("v", "<leader>cf", function()
							vim.lsp.buf.format({ bufnr = bufnr, name = client.name })
							vim.cmd("normal! ")
						end)
					end
				end,
			}
		end,
	},
}

-- {
-- 	"stevearc/conform.nvim",
-- 	---@module "conform"
-- 	---@type conform.setupOpts
-- 	opts = {
-- 		default_format_opts = {
-- 			lsp_format = "fallback",
-- 			timeout_ms = 500,
-- 		},
-- 		format_on_save = function(buf)
-- 			return vim.F.ok_or_nil(vim.F.if_nil(vim.b[buf].autoformat, vim.g.autoformat ~= false), {})
-- 		end,
-- 	},
-- },
-- {
-- 	"mfussenegger/nvim-lint",
-- 	lazy = true,
-- 	opts = {
-- 		-- Event to trigger linters
-- 		events = { "BufWritePost", "BufReadPost", "InsertLeave" },
-- 		linters_by_ft = {},
-- 		---@type table<string, lint.Linter>
-- 		linters = {},
-- 	},
-- 	config = function(_, opts)
-- 		local lint = require("lint")
--
-- 		for name, linter in pairs(opts.linters) do
-- 			if type(linter) == "table" and type(lint.linters[name]) == "table" then
-- 				lint.linters[name] = vim.tbl_deep_extend("force", lint.linters[name], linter)
-- 				if type(linter.prepend_args) == "table" then
-- 					lint.linters[name].args = lint.linters[name].args or {}
-- 					vim.list_extend(lint.linters[name].args, linter.prepend_args)
-- 				end
-- 			else
-- 				lint.linters[name] = linter
-- 			end
-- 		end
-- 		lint.linters_by_ft = opts.linters_by_ft
--
-- 		vim.api.nvim_create_autocmd(opts.events, {
-- 			group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
-- 			callback = require("util").debounce(100, function()
-- 				lint.try_lint()
-- 			end),
-- 		})
-- 	end,
-- },
