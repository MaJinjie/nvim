return {
  -- leap.nvim allows you to reach any target in a very fast, uniform way,
  -- and minimizes the required focus level while executing a jump.
  {
    "ggandor/leap.nvim",
    dependencies = "tpope/vim-repeat",
    event = "LazyFile",
    opts = {
      equivalence_classes = { " \t\r\n", "([{", ")]}", "'\"`" },
      preview_filter = function(ch0, ch1, ch2)
        return not (ch1:match("%s") or ch0:match("%w") and ch1:match("%w") and ch2:match("%w"))
      end,
    },
    -- stylua: ignore
    keys = {
      { "s", "<Plug>(leap)", mode = "n", desc = "Jump to the current window" },
      { "S", function() require("leap.remote").action() end, mode = "n", desc = "Leap Remote" },
      { "s", "<Plug>(leap-forward)", mode = "x", desc = "Jump to forward" },
      { "S", "<Plug>(leap-backward)", mode = "x", desc = "Jump to backward" },
      { "gs", function() require("leap.remote").action({input = "v"}) end, mode = "n", desc = "Leap Remote in char visual" },
      { "gS", function() require("leap.remote").action({input = "V"}) end, mode = "n", desc = "Leap Remote in line visual" },
      { "g<cr>", function() require("leap.treesitter").select() end, mode = { "n", "v", "o" }, desc = "Select Treesitter Node" },
    },
    config = function(_, opts)
      local leap = require("leap")
      for k, v in pairs(opts) do
        leap.opts[k] = v
      end
      require("leap.user").set_repeat_keys(";", ",")
    end,
  },
  {
    "ggandor/leap-spooky.nvim",
    dependencies = "ggandor/leap.nvim",
    event = "LazyFile",
    config = function()
      require("leap-spooky").setup {
        extra_text_objects = User.keymap.get_text_objects({ "i", "a" }),
      }
      User.util.on_lazyload("which-key.nvim", function()
        User.keymap.add_which_key({
          mode = { "o" },
          operators = {
            r = { group = "remote" },
            R = { group = "cross-remote" },
            m = { group = "magnetic" },
            M = { group = "cross-magnetic" },
          },
          objects = User.keymap.text_objects,
        })
      end)
    end,
  },
  -- f/F/t/T motions on steroids, building on the Leap interface.
  {
    "ggandor/flit.nvim",
    dependencies = "ggandor/leap.nvim",
    event = "LazyFile",
    opts = { labeled_modes = "nv" },
  },
}
