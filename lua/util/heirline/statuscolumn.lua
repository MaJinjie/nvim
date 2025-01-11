-- 1. 使用 左2 中 右3 的布局，左边是sign,mark 右边是git,fold 书写顺序即优先级
-- 2. 使用局部渲染，只计算当前窗口以及上下拓展的固定比例高度
-- 3. 缓存
--      在一个刷新间隔中，同一行决不会计算两次
--      将以buffer为单位符号计算和以行为单位的符号计算分离
--=============================== config
local config = {
	left = { "sign", "mark" },
	right = { "fold", "git" },
	pattern = {
		git = { "^GitSigns" },
	},
	refresh = 50,
	include_foldopen = false,
	height = 0.1,
	background = { bg = "dark4" },
}

---@type table<string, util.statuscolumn.Sign>
local sign_cache = {}
---@type table<string, table<number, util.statuscolumn.Sign[]>>
local line_cache = {}
---@type table<number, table<number, util.statuscolumn.Sign[]>>
local buf_cache = {}

--=============================== utils
local utils = {}

---@return util.statuscolumn.Sign[]
---@param self util.statuscolumn.Self
---@param clnum number
function utils.calc_line_signs(self, clnum)
	local buf, win = self.bufnr, self.winnr
	local key = ("%s:%s"):format(buf, win)

	line_cache[key] = line_cache[key] or {}
	if line_cache[key][clnum] then
		return line_cache[key][clnum]
	end

	local signs = {}
	vim.list_extend(signs, utils.calc_buf_signs(buf, clnum))
	vim.list_extend(signs, utils.calc_win_signs(win, clnum))

	line_cache[key][clnum] = signs
	return signs
end

---@param win integer
---@param clnum number
---@return util.statuscolumn.Sign[]
function utils.calc_win_signs(win, clnum)
	local signs = {}
	vim.api.nvim_win_call(win, function()
		-- Get fold signs
		if vim.fn.foldclosed(clnum) >= 0 then
			table.insert(signs, { text = vim.opt.fillchars:get().foldclose or "", texthl = "Folded", type = "fold" })
		elseif config.include_foldopen and tostring(vim.treesitter.foldexpr(clnum)):sub(1, 1) == ">" then
			table.insert(signs, { text = vim.opt.fillchars:get().foldopen or "", type = "fold" })
		end
	end)
	return signs
end

---@param str string?
---@return util.statuscolumn.Sign.type
local function get_sign_type(str)
	if str == nil or str == "" then
		return "sign"
	end
	for type, patterns in pairs(config.pattern) do
		for _, pattern in ipairs(patterns) do
			if str:find(pattern) then
				return type
			end
		end
	end
	return "sign"
end

---@param buf integer
---@param clnum number
---@return util.statuscolumn.Sign[]
function utils.calc_buf_signs(buf, clnum)
	buf_cache[buf] = buf_cache[buf] or {}

	if buf_cache[buf][clnum] and buf_cache[buf][clnum][0] then
		return buf_cache[buf][clnum]
	end

	local lsigns = buf_cache[buf]

	local function scan(slnum, elnum, step)
		for lnum = slnum, elnum, step do
			if lsigns[lnum] and lsigns[lnum][0] ~= true then
				return lnum - step
			end
			lsigns[lnum] = lsigns[lnum] or {}
			lsigns[lnum][0] = true
		end
		return elnum
	end

	-- Init number range
	local wt, wb = vim.fn.line("w0"), vim.fn.line("w$")
	local offset = math.floor(vim.api.nvim_win_get_height(0) * config.height)
	local slnum = scan(clnum - 1, math.max(1, wt - offset), -1)
	local elnum = scan(clnum, math.min(vim.fn.line("$"), wb + offset), 1)

	-- Get extmark signs
	local extmarks = vim.api.nvim_buf_get_extmarks(
		buf,
		-1,
		{ slnum - 1, 0 },
		{ elnum - 1, -1 },
		{ details = true, type = "sign" }
	)
	for _, extmark in ipairs(extmarks) do
		local type = get_sign_type(extmark[4].sign_hl_group)
		local text = extmark[4].sign_text
		local texthl = extmark[4].sign_hl_group
		local priority = extmark[4].priority
		local lnum = extmark[2] + 1

		table.insert(lsigns[lnum], { type = type, text = text, texthl = texthl, priority = priority })
	end

	if lsigns[0] ~= true then
		-- Get mark signs
		local marks = vim.list_extend(vim.fn.getmarklist(buf), vim.fn.getmarklist())
		for _, mark in ipairs(marks) do
			if mark.pos[1] == buf and mark.mark:match("[a-zA-Z]") then
				local lnum = mark.pos[2]
				lsigns[lnum] = lsigns[lnum] or {}
				table.insert(lsigns[lnum], { text = mark.mark:sub(2), texthl = "DiagnosticHint", type = "mark" })
			end
		end
		---@diagnostic disable-next-line: assign-type-mismatch
		lsigns[0] = true
	end

	-- Sort by priority
	for lnum = slnum, elnum do
		table.sort(lsigns[lnum], function(a, b)
			return (a.priority or 0) > (b.priority or 0)
		end)
	end

	return lsigns[clnum]
end

---@param self util.statuscolumn.Self
---@param clnum number
---@param types util.statuscolumn.Sign.type[]
---@return util.statuscolumn.Sign
function utils.get_line_sign(self, clnum, types)
	local key = ("%s:%s:%s:%s"):format(self.bufnr, self.winnr, clnum, table.concat(types, ","))

	if sign_cache[key] then
		return sign_cache[key]
	end

	local signs = utils.calc_line_signs(self, clnum)

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

--=============================== components
local components = {}

function components.fill()
	return { provider = "%=" }
end

function components.center()
	return {
		provider = function()
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
		condition = function()
			return vim.wo.signcolumn ~= "no"
		end,
		init = function(self)
			self.sign = utils.get_line_sign(self, vim.v.lnum, config.left)
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
		{
			provider = " ",
		},
		{
			condition = function(self)
				if vim.bo[self.bufnr].buftype ~= "" then
					return
				end
				return true
			end,
			init = function(self)
				self.sign = utils.get_line_sign(self, vim.v.lnum, config.right)
			end,
			provider = function(self)
				return self.sign.text
			end,
			hl = function(self)
				return self.sign.texthl
			end,
		},
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
			return vim.v.lnum >= vim.fn.line("w0") and vim.v.lnum <= vim.fn.line("w$")
		end,
		init = function(self)
			self.bufnr = vim.api.nvim_get_current_buf()
			self.winnr = vim.api.nvim_get_current_win()
		end,
		components.left(),
		components.fill(),
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
---@alias util.statuscolumn.Self {bufnr:number,winnr:number}
