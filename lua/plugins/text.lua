--[[ flash.nvim nvim-surround nvim-ufo ]]
--ufo [[zc zm zr zR      zj zk zp]]
--surround [[yv yvv yV cv cV dv dV vK VS]]
--comment [[gc(nxo) gb(nxo)]]
return {
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        -- aviod flash.nvim conflict
        keymaps = {
          normal = "yv",
          normal_cur = "yvv",
          normal_line = "yV",
          normal_cur_line = "yVV",
          visual = "K",
          visual_line = "S",
          delete = "dv",
          change = "cv",
          change_line = "cV",
        },
        -- surrounds = {},
        aliases = {
          ["a"] = "",
          ["s"] = "",
          ["B"] = "",
          ["r"] = "",
          ["q"] = { '"', "'", "`" },
          ["b"] = { "}", "]", ")", ">" },
        },
      })
    end,
  },
  {
    "kevinhwang91/nvim-ufo",
    event = "VeryLazy",
    config = function()
      vim.o.foldcolumn = "1" -- '0' is not bad
      vim.o.foldlevel = 99   -- Using ufo provider need a large value, feel free to decrease the value
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true

      local ufo = require("plugins.utils.ufo")
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
      }
      local language_servers = require("lspconfig").util.available_servers() -- or list servers manually like {'gopls', 'clangd'}
      for _, ls in ipairs(language_servers) do
        require("lspconfig")[ls].setup({
          capabilities = capabilities,
          -- you can add other fields for setting up lsp server in this table
        })
      end
      require("ufo").setup {
        close_fold_kinds = { 'imports', 'comment' }, -- when starter, close fold
        preview = {
          win_config = {
            winblend = 20
          },
          mappings = {
            scrollU = '<C-u>',
            scrollD = '<C-d>',
            -- jumpTop = '[',
            -- jumpBot = ']'
          }
        },
        provider_selector = function(bufnr, filetype, buftype)
          return ufo.ftMap[filetype] or ufo.customizeSelector
        end,
        fold_virt_text_handler = ufo.handler,
      }
      vim.keymap.set('n', 'zp', ufo.actions.peekFoldedLinesUnderCursor)
      vim.keymap.set('n', 'zk', ufo.actions.goPreviousClosedAndPeek)
      vim.keymap.set('n', 'zj', ufo.actions.goNextClosedAndPeek)
      vim.keymap.set('n', '[z', ufo.actions.goPreviousClosedAndPeek)
      vim.keymap.set('n', ']z', ufo.actions.goNextClosedAndPeek)
      vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
      vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
      vim.keymap.set('n', 'zr', require('ufo').openFoldsExceptKinds)
      vim.keymap.set('n', 'zm', require('ufo').closeFoldsWith) -- closeAllFolds == closeFoldsWith(0)
    end,
    dependencies = { "kevinhwang91/promise-async", "nvim-treesitter/nvim-treesitter" },
  },
  {
    'numToStr/Comment.nvim',
    event = "BufRead",
    config = function()
      require("Comment").setup {
        ignore = "^$",
      }
    end
  },

}


-- surrounds = {
--     ["("] =
--     [")"] =
--     ["{"] =
--     ["}"] =
--     ["<"] =
--     [">"] =
--     ["["] =
--     ["]"] =
--     ["'"] =
--     ['"'] =
--     ["`"] =
--     ["i"] = left right
--     ["t"] = html tag(not <>)
--     ["T"] = same as
--     ["f"] = function_name(...)
