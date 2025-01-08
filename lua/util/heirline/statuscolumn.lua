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
}

---@type table<string, util.statuscolumn.Sign>
local sign_cache = {}
---@type table<number, table<number, util.statuscolumn.Sign[]>>
local line_cache = {}
---@type table<number, table<number, util.statuscolumn.Sign[]>>
local buf_cache = {}

--=============================== utils
local utils = {}

---Get line signs
--- - sign
--- - fold
--- - git
---
---@return util.statuscolumn.Sign[]
---@param self util.statuscolumn.Self
function utils.calc_line_signs(self)
	local bufnr = self.bufnr
	local clnum = vim.v.lnum

	line_cache[bufnr] = line_cache[bufnr] or {}
	if line_cache[bufnr][clnum] then
		return line_cache[bufnr][clnum]
	end

	local lsigns = line_cache[bufnr]

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

	local function scan(slnum, elnum, step)
		for lnum = slnum, elnum, step do
			if lsigns[lnum] then
				return lnum - step
			end
			lsigns[lnum] = {}
		end
		return elnum
	end

	-- Init number range
	local _slnum, _elnum = self.slnum, self.elnum
	local slnum = scan(clnum - 1, _slnum, -1)
	local elnum = scan(clnum, _elnum, 1)

	local _remain_len = (_elnum - _slnum) - (elnum - slnum)
	if _remain_len > 0 then
		if _slnum == slnum then
			slnum = scan(_slnum - 1, math.max(1, _slnum - _remain_len), -1)
		end
		if _elnum == elnum then
			elnum = scan(_elnum + 1, math.min(vim.fn.line("$"), _elnum + _remain_len), 1)
		end
	end

  -- stylua: ignore start

	-- Get extmark signs
	local extmarks = vim.api.nvim_buf_get_extmarks( bufnr, -1, { slnum - 1, 0 }, { elnum - 1, -1 }, { details = true, type = "sign" })
	for _, extmark in ipairs(extmarks) do
		local type = get_sign_type(extmark[4].sign_hl_group)
		local text = extmark[4].sign_text
		local texthl = extmark[4].sign_hl_group
		local priority = extmark[4].priority
		local lnum = extmark[2] + 1

		table.insert(lsigns[lnum], { type = type, text = text, texthl = texthl, priority = priority })
	end

	-- Get fold signs
	for lnum = slnum, elnum do
		if vim.fn.foldclosed(lnum) >= 0 then
			table.insert(lsigns[lnum], { text = vim.opt.fillchars:get().foldclose or "", texthl = "Folded", type = "fold" })
		elseif config.include_foldopen and tostring(vim.treesitter.foldexpr(clnum)):sub(1, 1) == ">" then
			table.insert(lsigns[lnum], { text = vim.opt.fillchars:get().foldopen or "", type = "fold" })
		end
	end

  -- Get buf signs
  local bufsigns = utils.calc_buf_signs(self)
  for lnum = slnum, elnum do
    vim.list_extend(lsigns[lnum], bufsigns[lnum] or {})
  end

	-- Sort by priority
  for lnum = slnum, elnum do
    table.sort(lsigns[lnum], function(a, b) return (a.priority or 0) > (b.priority or 0) end)
  end

	-- stylua: ignore end

	return lsigns[clnum]
end

---Get buf signs
--- - marks
---
---@param self util.statuscolumn.Self
---@return util.statuscolumn.Sign[]
function utils.calc_buf_signs(self)
	local bufnr = self.bufnr

	-- 如果buf计算过，就直接返回
	if buf_cache[bufnr] then
		return buf_cache[bufnr]
	end

	local lsigns = {}

	-- Get mark signs
	local marks = vim.list_extend(vim.fn.getmarklist(bufnr), vim.fn.getmarklist())
	for _, mark in ipairs(marks) do
		if mark.pos[1] == bufnr and mark.mark:match("[a-zA-Z]") then
			local lnum = mark.pos[2]
			lsigns[lnum] = lsigns[lnum] or {}
			table.insert(lsigns[lnum], { text = mark.mark:sub(2), texthl = "DiagnosticHint", type = "mark" })
		end
	end

	buf_cache[bufnr] = lsigns
	return lsigns
end

---Get sign
---@param self util.statuscolumn.Self
---@param types util.statuscolumn.Sign.type[]
---@return util.statuscolumn.Sign
function utils.get_sign(self, types)
	local key = "" .. self.bufnr .. vim.v.lnum .. table.concat(types, ",")

	if sign_cache[key] then
		return sign_cache[key]
	end

	local signs = utils.calc_line_signs(self)

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
		hl = function(self)
			if self.clnum == vim.v.lnum then
				return "CursorLineNr"
			end
		end,
	}
end

function components.left()
	return {
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
				self.sign = utils.get_sign(self, config.right)
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
		condition = function(self)
			if vim.v.virtnum ~= 0 then
				return
			end

			local win_expand = math.floor(vim.api.nvim_win_get_height(0) * config.height)
			local win_start = vim.fn.line("w0") - win_expand
			local win_end = vim.fn.line("w$") + win_expand

			if vim.v.lnum >= win_start - win_expand and vim.v.lnum <= win_end + win_expand then
				self.slnum = math.max(1, win_start)
				self.clnum = vim.fn.line(".")
				self.elnum = math.min(vim.fn.line("$"), win_end)
				self.bufnr = vim.api.nvim_get_current_buf()
				self.winnr = vim.api.nvim_get_current_win()
				return true
			end
		end,
		hl = function(self)
			if self.clnum == vim.v.lnum then
				local hl_info = vim.api.nvim_get_hl(0, { name = "CursorLine", link = false })
				---@diagnostic disable-next-line: inject-field
				hl_info.force = true
				return hl_info
			end
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
---@alias util.statuscolumn.Self {bufnr:number,winnr:number,slnum:number,clnum:number,elnum:number}
