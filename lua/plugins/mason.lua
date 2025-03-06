local M = {}

function M.get_package_names()
  local opts = setmetatable({}, {
    __index = function(_, plugin)
      return User.util.get_plugin_opts(plugin)
    end,
  })
  local names = {}

  vim.list_extend(names, vim.tbl_keys(opts["nvim-lspconfig"]))

  vim.list_extend(names, vim.tbl_keys(opts["nvim-dap"]))

  for _, linters in pairs(opts["nvim-lint"].linters_by_ft) do
    if type(linters) == "table" then
      vim.list_extend(names, linters)
    end
  end

  for _, formatters in pairs(opts["conform.nvim"].formatters_by_ft) do
    if type(formatters) == "table" then
      vim.list_extend(names, formatters)
    end
  end

  return names
end

function M.get_package_aliases()
  local aliases = {
    require("mason-lspconfig.mappings.server").lspconfig_to_package,
    require("mason-nvim-dap.mappings.source").nvim_dap_to_package,
    require("mason-nvim-lint.mapping").nvimlint_to_package,
    require("mason-conform.mapping").conform_to_package,
  }

  local ret = {}
  local t = ret
  for _, alias in ipairs(aliases) do
    setmetatable(t, { __index = alias })
    t = getmetatable(t).__index
  end

  return ret
end

return {
  {
    "williamboman/mason.nvim",
    lazy = true,
    cmd = { "Mason" },
    ---@module 'mason'
    ---@type MasonSettings
    opts = {
      install_root_dir = vim.fs.joinpath(vim.env.XDG_DATA_HOME, "mason"),
      PATH = "skip",
      auto_install = true,
      ensure_installed = {},
      ignore_install = { "*", "_" },
      ui = {
        keymaps = {
          uninstall_package = "x",
          toggle_help = "?",
        },
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)

      local mr = require("mason-registry")

      mr.refresh(function()
        local names = opts.ensure_installed or {}
        if opts.auto_install then
          vim.list_extend(names, M.get_package_names())
        end
        names = User.util.dedup(names)

        local aliases = M.get_package_aliases()
        for _, name in ipairs(names) do
          if not (opts.ignore_install and vim.list_contains(opts.ignore_install, name)) then
            local pkg = mr.get_package(aliases[name] or name)
            if not pkg:is_installed() then
              pkg:install()
            end
          end
        end
      end)
    end,
  },
  { "williamboman/mason-lspconfig.nvim", lazy = true },
  { "zapling/mason-conform.nvim", lazy = true },
  { "rshkarin/mason-nvim-lint", lazy = true },
  { "jay-babu/mason-nvim-dap.nvim", lazy = true },
}
