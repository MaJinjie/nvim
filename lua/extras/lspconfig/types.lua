---@class user.lsp.Config
---@field enabled? boolean
---@field diagnostic? user.lsp.config.diagnostic
---@field keys? user.lsp.config.keys
---@field hooks? user.lsp.config.hooks
---@field opts? user.lsp.config.opts
---@field setup? user.lsp.config.setup

---@class user.lsp.config.diagnostic: vim.diagnostic.Opts
---@field enabled? boolean|fun(opts: user.lsp.Opts):boolean

---@alias user.lsp.config.keys user.lsp.config.key[]
---@class user.lsp.config.key: LazyKeysSpec, user.lsp.support

---@alias user.lsp.config.hooks table<number|string, user.lsp.config.hook>
---@alias user.lsp.config.hook user.lsp.config.hook_t|fun(opts: user.lsp.Opts)
---@class user.lsp.config.hook_t: user.lsp.support
---@field [number] fun(opts: user.lsp.Opts)

---@class user.lsp.config.opts: vim.lsp.ClientConfig,{}

---@alias user.lsp.config.setup fun(name:string, opts:user.lsp.config.opts):boolean?

---@class user.lsp.support
---@field ft? string|{[number]: string, exclude?: boolean}
---@field has? string|string[]
---@field cond? boolean|fun(opts: user.lsp.Opts):boolean

---@class user.lsp.Opts
---@field client vim.lsp.Client
---@field bufnr? number
