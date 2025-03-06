return {
  "kevinhwang91/nvim-bqf",
  ft = "qf",
  dependencies = "junegunn/fzf",
  init = function()
    User.util.on_filetype("ft", function(args)
      vim.keymap.set("n", "u", "<cmd>cdo undo<cr>", { desc = "Undo", buffer = args.buf })
      vim.keymap.set("n", "<C-r>", "<cmd>cdo redo<cr>", { desc = "Restore", buffer = args.buf })
      vim.keymap.set("n", "?", "<leader>?", { desc = "Show help", remap = true, buffer = args.buf })
    end)
  end,
  opts = {
    preview = { win_height = 10 },
    func_map = {
      open = "o",
      openc = "<cr>",
      tabb = "t",
      tab = "T",
      split = "<C-s>",
      prevfile = "K",
      nextfile = "J",
      ptogglemode = "M",
      filter = "n",
      filterr = "N",
      fzffilter = "/",
    },
    filter = {},
  },
}
