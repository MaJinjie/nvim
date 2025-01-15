local M = {}

---@param fn fun(client?:vim.lsp.Client, bufnr?:integer)
---@param client_name? string
function M.on_client_attach(fn, client_name)
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local bufnr = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and (client_name == nil or client.name == client_name) then
        fn(client, bufnr)
      end
    end,
  })
end

-- ---@param t util.lsp.Opts
-- ---@param opts {client:vim.lsp.Client,bufnr:integer}
-- function M.lsp(t, opts)
--   for k, v in pairs(t) do
--     M["lsp_" .. k](v, opts)
--   end
-- end
--
-- ---@param actions util.lsp.Action[]
-- ---@param opts {client:vim.lsp.Client,bufnr:integer}
-- function M.lsp_actions(actions, opts)
--   local client, bufnr = opts.client, opts.bufnr
--
--   local function support(methods)
--     if type(methods) == "string" then
--       return client.supports_method(methods, { bufnr = bufnr })
--     end
--     for _, method in ipairs(methods) do
--       if not support(method) then
--         return false
--       end
--     end
--     return true
--   end
--
--   for _, action in ipairs(actions) do
--     if not (action.has and not support(action.has)) and not (action.cond and not action.cond(client, bufnr)) then
--       if action.map then
--         local map = action.map
--         ---@cast map -nil
--         map = vim.tbl_deep_extend("keep", map, { nil, nil, nil, { buffer = bufnr, silent = true } })
--         vim.keymap.set(unpack(map))
--       end
--       if action.call then
--         action.call(client, bufnr)
--       end
--     end
--   end
-- end

---@param bufnr integer
---@param ... string
---@return string
function M.conform_first(bufnr, ...)
  local conform = require("conform")
  for i = 1, select("#", ...) do
    local formatter = select(i, ...)
    if conform.get_formatter_info(formatter, bufnr).available then
      return formatter
    end
  end
  return select(1, ...)
end

return M
