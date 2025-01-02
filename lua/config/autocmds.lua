local autocmd = vim.api.nvim_create_autocmd
local function augroup(name)
	return vim.api.nvim_create_augroup("_" .. name, { clear = true })
end

if vim.g.neovide then
	autocmd({ "InsertEnter", "InsertLeave" }, {
		group = augroup("ime-input"),
		callback = function(ev)
			if ev.event:match("Leave$") then
				vim.g.neovide_input_ime = false
			else
				vim.g.neovide_input_ime = true
			end
		end,
	})
end

autocmd({ "VimResized" }, {
	group = augroup("resize_splits"),
	command = ":wincmd =",
})

-- set options for some filetypes
autocmd("FileType", {
	group = augroup("set_options"),
	pattern = { "man", "qf", "checkhealth" },
	callback = function(event)
		vim.bo[event.buf].buflisted = false
	end,
})
