--=============================== config
local config = {
	left = { "sign" },
	right = { "fold", "git" },
	git_pattern = "GitSign",
	refresh = 50,
}

---@type table<string, string>
local text_cache = {}
---@type table<number, table<number, util.statuscolumn.Sign[]>>
local line_cache = {}
---@type table<number, table<number, util.statuscolumn.Sign[]>>
local buf_cache = {}

--=============================== utils
local utils = {}

---Find first sign
---@param signs util.statuscolumn.Sign[]
---@param types util.statuscolumn.Sign.type[]
---@param all? boolean
---@return table<util.statuscolumn.Sign.type, util.statuscolumn.Sign>
function utils.find(signs, types, all)
	local sign_by_type = {} ---@type table<util.statuscolumn.Sign.type, util.statuscolumn.Sign>
	-- 按优先级搜索
	for _, sign in ipairs(signs) do
		for _, type in ipairs(types) do
			if sign.type == type then
				sign_by_type[type] = sign_by_type[type] or sign
				break
			end
		end
		if not all and next(sign_by_type) then
			break
		end
	end
	return sign_by_type
end

---Get text
---@param text? string
---@param align? "l"|"r"
---@param size? number
---@return string
function utils.get_text(text, align, size)
	text = text or ""
	align = align or "l"
	size = size or 2

	local key = text .. align .. size
	if text_cache[key] then
		return text_cache[key]
	end

	if align == "l" then
		text = vim.fn.strcharpart(text:match("^%s*(.*)"), 0, size)
		text = text .. string.rep(" ", size - vim.fn.strchars(text))
	else
		text = vim.fn.strcharpart(text:match("(.-)%s*$"), 0, size)
		text = string.rep(" ", size - vim.fn.strchars(text)) .. text
	end

	text_cache[key] = text
	return text
end

---Add other signs
---@return util.statuscolumn.Sign[]
---@param buf number
---@param lnum number
function utils.calc_sign(buf, lnum)
	if line_cache[buf][lnum] then
		return line_cache[buf][lnum]
	end

	local lsigns = {} ---@type util.statuscolumn.Sign[]

	-- Get extmark signs
	local extmarks = vim.api.nvim_buf_get_extmarks(
		buf,
		-1,
		{ lnum - 1, 0 },
		{ lnum - 1, -1 },
		{ details = true, type = "sign" }
	)
	for _, extmark in pairs(extmarks) do
		local type = (extmark[4].sign_hl_group or ""):find(config.git_pattern, 1, true) == 1 and "git" or "sign"

		table.insert(lsigns, {
			type = type,
			text = extmark[4].sign_text,
			texthl = extmark[4].sign_hl_group,
			priority = extmark[4].priority,
		})
	end

	if vim.fn.foldclosed(lnum) >= 0 then
		table.insert(lsigns, { text = vim.opt.fillchars:get().foldclose or "", texthl = "Folded", type = "fold" })
	elseif tostring(vim.treesitter.foldexpr(lnum)):sub(1, 1) == ">" then
		table.insert(lsigns, { text = vim.opt.fillchars:get().foldopen or "", type = "fold" })
	end

	-- Sort by priority
	table.sort(lsigns, function(a, b)
		return (a.priority or 0) > (b.priority or 0)
	end)

	line_cache[buf][lnum] = lsigns
	return lsigns
end

---Get mark signs
---@param buf number
---@param lnum? number
---@return util.statuscolumn.Sign[]
function utils.calc_mark(buf, lnum)
	if lnum then
		return buf_cache[buf][lnum] or {}
	end

	local lmarks = {}
	local marks = vim.list_extend(vim.fn.getmarklist(buf), vim.fn.getmarklist())
	for _, mark in ipairs(marks) do
		if mark.pos[1] == buf and mark.mark:match("[a-zA-Z]") then
			local lnum = mark.pos[2]
			lmarks[lnum] = lmarks[lnum] or {}
			table.insert(lmarks[lnum], { text = mark.mark:sub(2), texthl = "DiagnosticHint", type = "mark" })
		end
	end
	return lmarks
end

--=============================== components
local components = {}

function components.placeholder()
	return { provider = "%=" }
end

function components.center()
	return {
		provider = function(self)
			if vim.o.number or vim.o.relativenumber then
				local lnum
				if vim.v.relnum == 0 then
					lnum = vim.o.number and vim.v.lnum or vim.v.relnum
				else
					lnum = vim.o.relativenumber and vim.v.relnum or vim.v.lnum
				end
				return lnum
			end
		end,
	}
end

function components.left()
	return {
		condition = function(self)
			return vim.bo[self.buf].buftype == ""
		end,
		init = function(self)
			local lsigns = utils.calc_sign(self.buf, vim.v.lnum)
			local lmarks = utils.calc_mark(self.buf, vim.v.lnum)
			local _, sign = next(utils.find(vim.list_extend(lsigns, lmarks), { "sign", "mark" }))

			if sign then
				self.text = utils.get_text(sign.text)
				self.texthl = sign.texthl
			else
				self.text = "  "
				self.texthl = nil
			end
		end,
		provider = function(self)
			return self.text
		end,
		hl = function(self)
			return self.texthl
		end,
	}
end

function components.right()
	return {
		condition = function(self)
			return vim.bo[self.buf].buftype == ""
		end,
		init = function(self)
			local lsigns = utils.calc_sign(self.buf, vim.v.lnum)
			local _, sign = next(utils.find(lsigns, { "fold", "git" }))

			if sign then
				self.text = utils.get_text(sign.text, sign.type ~= "git" and "l" or "r")
				self.texthl = sign.texthl
			else
				self.text = "  "
				self.texthl = nil
			end
		end,
		provider = function(self)
			return self.text
		end,
		hl = function(self)
			return self.texthl
		end,
	}
end
--=============================== setup
local M = {}

M.init = function()
	M.config = {
		condition = function(self)
			if vim.v.virtnum ~= 0 then
				return
			end
			self.buf = vim.api.nvim_get_current_buf()
			self.win = vim.api.nvim_get_current_win()

			local w_slnum = vim.fn.line("w0", self.win)
			local w_elnum = vim.fn.line("w$", self.win)
			local w_height = vim.fn.winheight(self.win)

			return vim.v.lnum >= w_slnum - w_height and vim.v.lnum <= w_elnum + w_height
		end,
		init = function(self)
			line_cache[self.buf] = line_cache[self.buf] or {}

			-- 添加buf缓存
			if not buf_cache[self.buf] then
				buf_cache[self.buf] = {}
				for lnum, lmarks in pairs(utils.calc_mark(self.buf)) do
					buf_cache[self.buf][lnum] = vim.list_extend(buf_cache[self.buf][lnum] or {}, lmarks)
				end
			end
		end,
		components.left(),
		components.placeholder(),
		components.center(),
		components.right(),
	}
end

M.setup = function()
	local timer = assert(vim.uv.new_timer())
	timer:start(config.refresh, config.refresh, function()
		line_cache = {}
		buf_cache = {}
	end)
end
return M

---@alias util.statuscolumn.Sign.type "mark"|"sign"|"fold"|"git"
---@alias util.statuscolumn.Sign {text:string, texthl:string, priority:number, type:util.statuscolumn.Sign.type}
