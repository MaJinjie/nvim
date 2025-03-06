return {
  "mfussenegger/nvim-lint",
  event = "BufReadPost",
  opts = {
    -- Event to trigger linters
    events = { "BufWritePost", "BufReadPost", "InsertLeave" },
    linters_by_ft = {
      ["*"] = { "typos" },
      sh = { "shellcheck" },
    },
    -- To easily override linter options or add custom linters.
    ---@type table<string,user.lint.Linter>
    linters = {
      typos = {
        condition = function(_, ctx)
          return vim.bo[ctx.bufnr].buftype == ""
        end,
      },
    },
  },
  config = function(_, opts)
    local utils = require("extras.lint.utils")
    local lint = require("lint")

    for name, linter in pairs(opts.linters) do
      if type(linter) == "table" and type(lint.linters[name]) == "table" then
        lint.linters[name] = vim.tbl_deep_extend("force", lint.linters[name] --[[@as table]], linter)
        if type(linter.prepend_args) == "table" then
          lint.linters[name].args = lint.linters[name].args or {}
          vim.list_extend(lint.linters[name].args, linter.prepend_args)
        end
      else
        lint.linters[name] = linter
      end
    end
    lint.linters_by_ft = opts.linters_by_ft

    vim.api.nvim_create_autocmd(opts.events, {
      group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
      callback = User.util.debounce(function()
        local names = utils.list_linters_for_buffer()
        -- Run linters.
        if #names > 0 then
          lint.try_lint(names)
        end
      end),
    })
  end,
}
