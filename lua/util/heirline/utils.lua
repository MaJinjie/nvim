---@diagnostic disable: missing-fields
local M = {}

local function tbl_insert(t, dir, ...)
	for i = 1, select("#", ...) do
		local e = select(i, ...)
		if dir:sub(1, 1) == "l" then
			table.insert(t, 1, e)
		else
			table.insert(t, e)
		end
	end
end

function M.flatten(component)
	if component.provider then
		local new = { provider = component.provider }
		component.provider = nil
		if #component > 0 then
			for i = 1, #component do
				table.insert(new, component[i])
				component[i] = nil
			end
		end
		table.insert(component, new)
	end
	return component
end

---@param component StatusLine
---@param opts {left?:number|string, right?:number|string}|any
function M.padding(component, opts)
	if not opts then
		return component
	end

	opts = type(opts) ~= "table" and { left = 1, right = 1 } or opts

	if component.provider then
		component = M.flatten(component)
	end

	for dir, n_or_s in pairs(opts) do
		tbl_insert(component, dir, { provider = type(n_or_s) == "number" and (" "):rep(n_or_s) or n_or_s })
	end
	return component
end

---@param component StatusLine
---@param opts {padding?:any,delimiter?:{left?:string, right?:string, out?:true, hl:any},[string]:any}
function M.surround(component, opts)
	if not opts.padding and not opts.delimiter then
		return component
	end

	if component.provider then
		component = M.flatten(component)
	end

	if opts.padding then
		M.padding(component, opts.padding)
		opts.padding = nil
	end

	if opts.delimiter then
		local delimiter_hl = opts.delimiter.hl
		opts.delimiter.hl = nil
		if opts.delimiter.out then
			component = { component }
			opts.delimiter.out = nil
		end
		for dir, str in pairs(opts.delimiter) do
			tbl_insert(component, dir, { provider = str, hl = delimiter_hl })
		end
		opts.delimiter = nil
	end

	return vim.tbl_extend("force", component, opts)
end

---@param components StatusLine[]
---@param opts {separator:(string|fun(self?:StatusLine):string),delimiter?:{left?:string,right?:string},[string]:any}
function M.concat(components, opts)
	if #components == 0 then
		return components
	end
	local res = {}

	local separator_condition = function(self)
		local id = self.id[#self.id]

		local parent_component = getmetatable(self)
		local prev_component = parent_component:get({ id - 1 })
		local next_component = parent_component:get({ id + 1 })

		if prev_component.condition and not prev_component:condition() then
			return false
		end
		if next_component.condition and not next_component:condition() then
			return false
		end
		return true
	end

	for i = 1, #components do
		if i > 1 then
			table.insert(res, {
				provider = opts.separator,
				condition = separator_condition,
			})
		end
		table.insert(res, components[i])
	end
	opts.separator = nil

	if opts.delimiter then
		M.padding(res, opts.delimiter)
		opts.delimiter = nil
	end

	return vim.tbl_extend("force", res, opts)
end

function M.make_tablist(...)
	return require("heirline.utils").make_tablist(...)
end

function M.make_buflist(...)
	return require("heirline.utils").make_buflist(...)
end

return setmetatable({}, { __index = M })
