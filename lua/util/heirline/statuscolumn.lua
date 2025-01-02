-- 1. 使用 左2 中 右2 的布局，左边是sign,mark 右边是git,fold 书写顺序即优先级
-- 2. 使用局部渲染，只计算当前窗口以及上一个窗口(C-b)和下一窗口(C-f)
-- 3. 这种范围渲染最好使用范围计算，而我为了简单使用单行计算
-- 4. 缓存
--=============================== config
local config = {
	left = { "sign", "mark" },
	right = { "fold", "git" },
	git_pattern = "GitSign",
	refresh = 75,
	include_foldopen = true,
	height = 1,
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

---Get line signs
--- - sign
--- - fold
--- - git
---
---@return util.statuscolumn.Sign[]
---@param self util.statuscolumn.Self
function utils.calc_line_sign(self)
	local buf = self.buf
	local num = vim.v.lnum

	line_cache[buf] = line_cache[buf] or {}
	if line_cache[buf][num] then
		return line_cache[buf][num]
	end

	local signs = {} ---@type util.statuscolumn.Sign[]

	-- Get extmark signs
	local extmarks = vim.api.nvim_buf_get_extmarks(
		buf,
		-1,
		{ num - 1, 0 },
		{ num - 1, -1 },
		{ details = true, type = "sign" }
	)
	for _, extmark in pairs(extmarks) do
		local type = (extmark[4].sign_hl_group or ""):find(config.git_pattern, 1, true) == 1 and "git" or "sign"

		table.insert(signs, {
			type = type,
			text = extmark[4].sign_text,
			texthl = extmark[4].sign_hl_group,
			priority = extmark[4].priority,
		})
	end

	-- cale fold
	if vim.fn.foldclosed(num) >= 0 then
		table.insert(signs, { text = vim.opt.fillchars:get().foldclose or "", texthl = "Folded", type = "fold" })
	elseif config.include_foldopen and tostring(vim.treesitter.foldexpr(num)):sub(1, 1) == ">" then
		table.insert(signs, { text = vim.opt.fillchars:get().foldopen or "", type = "fold" })
	end

	-- cale buf signs
	vim.list_extend(signs, utils.cale_buf_sign(self))

	-- Sort by priority
	table.sort(signs, function(a, b)
		return (a.priority or 0) > (b.priority or 0)
	end)

	line_cache[buf][num] = signs
	return utils.calc_line_sign(self)
end

---Get buf signs
--- - marks
---
---@param self util.statuscolumn.Self
---@return util.statuscolumn.Sign[]
function utils.cale_buf_sign(self)
	local buf = self.buf
	local num = vim.v.lnum

	-- 如果buf计算过，就直接返回
	if buf_cache[buf] then
		return buf_cache[buf][num] or {}
	end

	local lsigns = {}

	-- calc marks
	local marks = vim.list_extend(vim.fn.getmarklist(buf), vim.fn.getmarklist())
	for _, mark in ipairs(marks) do
		if mark.pos[1] == buf and mark.mark:match("[a-zA-Z]") then
			local lnum = mark.pos[2]
			lsigns[lnum] = lsigns[lnum] or {}
			table.insert(lsigns[lnum], { text = mark.mark:sub(2), texthl = "DiagnosticHint", type = "mark" })
		end
	end

	buf_cache[buf] = lsigns
	return utils.cale_buf_sign(self)
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
			if vim.o.number and vim.v.lnum > 999 then
				return
			end
			return true
		end,
		init = function(self)
			local signs = utils.calc_line_sign(self)
			local _, sign = next(utils.find(signs, config.left))

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
			if vim.bo[self.buf].buftype ~= "" then
				return
			end
			return true
		end,
		init = function(self)
			local signs = utils.calc_line_sign(self)
			local _, sign = next(utils.find(signs, config.right))

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
		condition = function()
			if vim.v.virtnum ~= 0 then
				return
			end

			local w_slnum = vim.fn.line("w0")
			local w_elnum = vim.fn.line("w$")
			local w_height = math.floor(vim.api.nvim_win_get_height(0) * config.height)

			return vim.v.lnum >= w_slnum - w_height and vim.v.lnum <= w_elnum + w_height
		end,
		init = function(self)
			self.buf = vim.api.nvim_get_current_buf()
			self.win = vim.api.nvim_get_current_win()
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
---@alias util.statuscolumn.Self {buf:number, win:number}
