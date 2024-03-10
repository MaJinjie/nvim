local opts = require "plugins.configs.cmp"
local cmp = require "cmp"
local defaults = require "cmp.config.default"()
local luasnip = require "luasnip"
-- sources
local set_sources = cmp.config.sources({
  { name = "nvim_lsp" },
  { name = "path" },
  { name = "luasnip" },
}, {
  { name = "buffer" },
})

-- autocmds
vim.api.nvim_create_autocmd("BufReadPre", {
  callback = function(t)
    local sources = set_sources
    local ft = vim.api.nvim_buf_get_option(t.buf, "filetype")
    if ft == "tmux" then
      sources[#sources + 1] = { name = "tmux", group_index = 2 }
    end
    if ft == "zsh" then
      sources[#sources + 1] = { name = "zsh", group_index = 2 }
    end
    cmp.setup.buffer {
      sources = sources,
    }
  end,
})
-- function

local has_words_before = function()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
end
-- mappgins
local mappings = {
  ["<C-b>"] = cmp.mapping.scroll_docs(-4),
  ["<C-f>"] = cmp.mapping.scroll_docs(4),
  ["<C-d>"] = function(fallback) -- toggle doc
    if cmp.visible_docs() then
      cmp.close_docs()
    else
      cmp.open_docs()
    end
  end,
  ["<C-o>"] = cmp.mapping.abort(),
  ["<CR>"] = cmp.mapping.confirm { select = false },
  ["<C-n>"] = function(fallback)
    if cmp.visible() then
      if #cmp.get_entries() == 1 then
        cmp.confirm { select = true }
      else
        cmp.select_next_item { behavior = cmp.SelectBehavior.InsertEnter }
      end
    elseif luasnip.expand_or_jumpable() then -- when local , -> expand_or_locally_jumpable
      luasnip.expand_or_jump(1)
    elseif has_words_before() then
      cmp.complete()
    else
      fallback()
    end
  end,
  ["<C-p>"] = function(fallback)
    if cmp.visible() then
      cmp.select_prev_item { behavior = cmp.SelectBehavior.InsertEnter }
    elseif luasnip.expand_or_jumpable() then -- when local , -> expand_or_locally_jumpable
      luasnip.jump(-1)
    else
      fallback()
    end
  end,
}
mappings["<Tab>"] = mappings["<C-n>"]
mappings["<S-Tab>"] = mappings["<C-p>"]

-- function
local select_mappings = function(modes, ...)
  modes = type(modes) == "table" and modes or { modes }
  local mps = {}
  for _, key in pairs { ... } do
    mps[key] = cmp.mapping(mappings[key], modes)
  end
  return mps
end

-- setup
cmp.setup {
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  completion = {
    completeopt = "menu,menuone",
  },
  window = {
    completion = cmp.config.window.bordered {
      side_padding = 1,
      scrolloff = 2,
      winhighlight = "Normal:CmpPmenu,CursorLine:CmpSel,Search:None",
    },
    documentation = {
      border = "shadow",
      winhighlight = "Normal:CmpDoc",
    },
  },

  -- cmdline completion from down to up
  view = {
    entries = { name = "custom", selection_order = "near_cursor" },
  },
  mapping = select_mappings(
    { "i", "s" },
    "<CR>",
    "<C-b>",
    "<C-f>",
    "<C-o>",
    "<Tab>",
    "<S-Tab>",
    "<C-n>",
    "<C-p>",
    "<C-d>"
  ),
  formatting = opts.formatting,
  sources = set_sources,
  sorting = defaults.sorting,
}
-- cmdline
cmp.setup.cmdline({ "/", "?" }, {
  completion = {
    completeopt = "menu,menuone",
    keyword_length = 1,
  },
  mapping = select_mappings({ "c" }, "<CR>", "<C-o>", "<Tab>", "<S-tab>"),
  sources = {
    { name = "buffer", keyword_length = 3 },
  },
})
cmp.setup.cmdline({ ":" }, {
  mapping = select_mappings({ "c" }, "<CR>", "<C-o>", "<Tab>", "<S-tab>"),
  sources = cmp.config.sources(
    { { name = "path", keyword_length = 1 } },
    { { name = "cmdline", keyword_length = 2 } },
    { { name = "cmdline_history", keyword_length = 10 }, { name = "buffer", keyword_length = 3 } }
  ),
})

-- local capabilities = require("cmp_nvim_lsp").default_capabilities()
-- require("lspconfig")["lua_ls"].setup {
--   capabilities = { capabilities },
-- }
