local M = {}

--- 防抖动
---
---@param ms integer
---@param fn fun()
function M.debounce(ms, fn)
	local timer = assert(vim.uv.new_timer())
	return function(...)
		local argv = { ... }
		timer:start(ms, 0, function()
			timer:stop()
			vim.schedule_wrap(fn)(unpack(argv))
		end)
	end
end

--=================================================== git

---@param path string
---@return boolean is_git
function M.is_git_repo(path)
	vim.fn.system(("git -C %s rev-parse --is-inside-work-tree"):format(path))
	return vim.v.shell_error == 0
end

---@param path string
---@return string? GIT_WORK_TREE
function M.get_git_root(path)
	local root = vim.fn.system(("git -C %s rev-parse --show-toplevel"):format(path))
	return vim.v.shell_error == 0 and vim.fs.normalize(vim.trim(root)) or nil
end

--=================================================== plugin
---@param name string
function M.get_plugin(name)
	return require("lazy.core.config").spec.plugins[name]
end

---@param plugin string
function M.has_plugin(plugin)
	return M.get_plugin(plugin) ~= nil
end

---@param name string
function M.get_plugin_opts(name)
	local plugin = M.get_plugin(name)
	if not plugin then
		return {}
	end
	local Plugin = require("lazy.core.plugin")
	return Plugin.values(plugin, "opts", false)
end

---@param fn fun(ev?:table) | vim.api.keyset.create_autocmd
function M.on_very_lazy(fn)
	---@type vim.api.keyset.create_autocmd
	local opts = { pattern = "VeryLazy", once = true }

	if type(fn) == "function" then
		opts.callback = fn
	else
		opts = vim.tbl_extend("error", fn, opts)
	end
	vim.api.nvim_create_autocmd("User", opts)
end

return M
