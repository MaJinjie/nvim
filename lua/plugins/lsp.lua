---@diagnostic disable: missing-fields
local theme = require("config.theme")

local lazy_load = { "neovim/nvim-lspconfig", "stevearc/conform.nvim" }

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
					for _, tool in ipairs(opts.ensure_installed or {}) do
						local p = require("mason-registry").get_package(tool)
						if not p:is_installed() then
							p:install()
						end
					end
					require("lazy").load({ plugins = lazy_load })
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
						opts = vim.tbl_extend("force", { buffer = bufnr, silent = true }, opts)
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
						if support("textDocument/hover") then map("n", "gk", vim.lsp.buf.hover) end
						if support("textDocument/signatureHelp") then map("n", "gK", vim.lsp.buf.signature_help) end

						if support("textDocument/rename") then map("n", "<leader>cr", vim.lsp.buf.rename) end
						if support("textDocument/codeAction") then map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action) end
					-- stylua: ignore end

					if support("textDocument/inlayHint") then
						vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
					end
				end,
			},
		},
		config = function(self, opts)
			vim.diagnostic.config(opts.diagnostic)

			local f = vim.schedule_wrap(function()
				local lspconfig = require("lspconfig")

				local default_opts = opts.default
				default_opts.capabilities = require("blink-cmp").get_lsp_capabilities(default_opts.capabilities, true)

				for _, opt_name in ipairs(self.opts_extend) do
					opts[opt_name] = nil
				end

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
				for server, server_opts in pairs(opts) do
					server_setup(server, server_opts)
				end
			end)

			local check = assert(vim.uv.new_check())
			vim.uv.check_start(check, function()
				if is_install_finished then
					vim.uv.check_stop(check)
					f()
				end
			end)

			vim.defer_fn(function()
				if not is_install_finished then
					vim.uv.check_stop(check)
					vim.notify("Mason installation timed out.\nLsp don't startup.", "error", { title = "Mason|Lsp" })
				end
			end, 5000)
		end,
	},
	{
		"stevearc/conform.nvim",
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
}
