-- 1. 使用 左2 中 右3 的布局，左边是sign,mark 右边是git,fold 书写顺序即优先级
-- 2. 使用局部渲染，只计算当前窗口以及上一个窗口(C-b)和下一窗口(C-f)
-- 3. 这种范围渲染最好使用范围计算，而我为了简单使用单行计算
-- 4. 缓存
--=============================== config
local config = {
	left = { "sign", "mark" },
	right = { "fold", "git" },
	git_pattern = "GitSign",
	refresh = 50,
	include_foldopen = false,
	height = 0.5,
}

---@type table<string, util.statuscolumn.Sign>
local sign_cache = {}
---@type table<number, table<number, util.statuscolumn.Sign[]>>
local line_cache = {}
---@type table<number, table<number, util.statuscolumn.Sign[]>>
local buf_cache = {}

--=============================== utils
local utils = {}

---Get sign
---@param self util.statuscolumn.Self
---@param types util.statuscolumn.Sign.type[]
---@return util.statuscolumn.Sign
function utils.get_sign(self, types)
	local key = "" .. self.buf .. vim.v.lnum .. table.concat(types, ",")

	if sign_cache[key] then
		return sign_cache[key]
	end

	local signs = utils.calc_line_sign(self)

	local sign = (function()
		for _, sign in ipairs(signs) do
			for _, type in ipairs(types) do
				if sign.type == type then
					return sign
				end
			end
		end
	end)()

	if sign then
		sign.text = vim.fn.strcharpart(sign.text, 0, 2)
		sign.text = sign.text .. string.rep(" ", 2 - vim.fn.strchars(sign.text))
	else
		sign = { text = "  " }
	end

	sign_cache[key] = sign
	return sign
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
	return signs
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
	return lsigns[num] or {}
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
			self.sign = utils.get_sign(self, config.left)
		end,
		provider = function(self)
			return self.sign.text
		end,
		hl = function(self)
			return self.sign.texthl
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
			self.sign = utils.get_sign(self, config.right)
		end,
		provider = function(self)
			return " " .. self.sign.text
		end,
		hl = function(self)
			return self.sign.texthl
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
		sign_cache = {}
		line_cache = {}
		buf_cache = {}
	end)
end
return M

---@alias util.statuscolumn.Sign.type "mark"|"sign"|"fold"|"git"
---@alias util.statuscolumn.Sign {text:string, texthl:string, priority:number, type:util.statuscolumn.Sign.type}
---@alias util.statuscolumn.Self {buf:number}
