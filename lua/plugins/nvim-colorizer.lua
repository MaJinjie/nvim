local M = {}

function M.colorize(state, bufnr)
  if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].buftype ~= "nofile" then
    if state then
      require("colorizer").attach_to_buffer(bufnr)
    else
      require("colorizer").detach_from_buffer(bufnr)
    end
  end
end

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  group = vim.api.nvim_create_augroup("user_attach_colorizer", { clear = true }),
  callback = function(args)
    if vim.b[args.buf].autocolorize or vim.g.autocolorize then
      M.colorize(true, args.buf)
    end
  end,
})

User.keymap.toggle["<leader>uH"] = function()
  return Snacks.toggle({
    name = "Auto Colorize to Buffer",
    get = function()
      return vim.g.autocolorize
    end,
    set = function(state)
      vim.g.autocolorize = state
      vim.b.autocolorize = nil

      for buf in vim.iter(vim.api.nvim_list_bufs()):filter(vim.api.nvim_buf_is_loaded) do
        if vim.b[buf].autocolorize == nil then
          M.colorize(state, buf)
        end
      end
    end,
  })
end

-- A high-performance color highlighter for Neovim which has no external dependencies! Written in performant Luajit.
return {
  "norcalli/nvim-colorizer.lua",
  event = "LazyFile",
  opts = {},
}
