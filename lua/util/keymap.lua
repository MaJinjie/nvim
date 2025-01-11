local M = {}

--- Delete a buffer:
--- - either the current buffer if `buf` is not provided
--- - or the buffer `buf` if it is a number
--- - or every buffer for which `buf` returns true if it is a function
---@param opts? number|(fun(buf?:number):boolean)|util.bufdelete.Opts
function M.buf_delete(opts)
	opts = opts or {}
	opts = type(opts) == "number" and { buf = opts } or opts
	opts = type(opts) == "function" and { filter = opts } or opts
	---@diagnostic disable-next-line: cast-type-mismatch
	---@cast opts util.bufdelete.Opts

	if type(opts.filter) == "function" then
		for _, b in ipairs(vim.tbl_filter(opts.filter, vim.api.nvim_list_bufs())) do
			if vim.bo[b].buflisted then
				M.delete(vim.tbl_extend("force", {}, opts, { buf = b, filter = false }))
			end
		end
		return
	end

	local buf = opts.bufnr or 0
	buf = buf == 0 and vim.api.nvim_get_current_buf() or buf

	vim.api.nvim_buf_call(buf, function()
		if vim.bo.modified and not opts.force then
			local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
			if choice == 0 or choice == 3 then -- 0 for <Esc>/<C-c> and 3 for Cancel
				return
			end
			if choice == 1 then -- Yes
				vim.cmd.write()
			end
		end

		for _, win in ipairs(vim.fn.win_findbuf(buf)) do
			vim.api.nvim_win_call(win, function()
				if not vim.api.nvim_win_is_valid(win) or vim.api.nvim_win_get_buf(win) ~= buf then
					return
				end
				-- Try using alternate buffer
				local alt = vim.fn.bufnr("#")
				if alt ~= buf and vim.fn.buflisted(alt) == 1 then
					vim.api.nvim_win_set_buf(win, alt)
					return
				end

				-- Try using previous buffer
				local has_previous = pcall(vim.cmd, "bprevious")
				if has_previous and buf ~= vim.api.nvim_win_get_buf(win) then
					return
				end

				-- Create new listed buffer
				local new_buf = vim.api.nvim_create_buf(true, false)
				vim.api.nvim_win_set_buf(win, new_buf)
			end)
		end
		if vim.api.nvim_buf_is_valid(buf) then
			pcall(vim.cmd, (opts.wipe and "bwipeout! " or "bdelete! ") .. buf)
		end
	end)
end

function M.tab_switch()
	local tabnr = vim.fn.tabpagenr("#")
	if tabnr == 0 then
		vim.cmd("tabnew %")
	else
		vim.cmd("tabnext " .. tabnr)
	end
end

function M.quit()
	-- 如果当前标签页还有多个窗口，先关闭窗口
	if #vim.api.nvim_tabpage_list_wins(0) > 1 then
		vim.cmd("close")
	-- 如果只有一个窗口，但还有多个标签页，关闭当前标签页
	elseif #vim.api.nvim_list_tabpages() > 1 then
		vim.cmd("tabclose")
	-- 如果仅剩最后一个标签页和窗口，退出 Vim
	else
		vim.cmd("quit")
	end
end

---@package
M._toggle = {} ---@type table<any, boolean>

---@param name string
---@param opts? string|(fun(state?:boolean):boolean)|{set:(fun(state?:boolean)),get:(fun():boolean)}
---@return boolean
function M.toggle(name, opts)
	local function notify(context, flag)
		if flag ~= nil then
			context = flag and "Enable " .. context or "Disable " .. context
		end
		vim.notify(context, vim.log.levels.INFO, { title = "Toggle" })
	end
	opts = opts or name

	if type(opts) == "string" then
		---@cast opts string
		vim.cmd(opts)
		notify(name)
	elseif type(opts) == "function" then
		---@cast opts fun(state?:boolean):boolean
		M._toggle[name] = opts(M._toggle[name])
		notify(name, M._toggle[name])
	else
		---@cast opts {set:(fun(state?:boolean)),get:(fun():boolean)}
		opts.set(not opts.get())
		notify(name, opts.get())
	end
	return M._toggle[name]
end

return M

---@class util.bufdelete.Opts
---@field bufnr? number Buffer to delete. Defaults to the current buffer
---@field force? boolean Delete the buffer even if it is modified
---@field filter? fun(buf: number): boolean Filter buffers to delete
---@field wipe? boolean Wipe the buffer instead of deleting it (see `:h :bwipeout`)
