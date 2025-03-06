return {
  "kylechui/nvim-surround",
  event = "LazyFile",
  opts = function(_, opts)
    local surround_char, surround_line = "s", "S"

    opts.move_cursor = "sticky"
    opts.keymaps = {
      insert = "<C-g>",
      insert_line = "<C-g>",
      normal = "y",
      normal_cur = "y",
      normal_line = "y",
      normal_cur_line = "y",
      visual = "g",
      visual_line = "g",
      delete = "d",
      change = "c",
      change_line = "c",
    }
    opts.surrounds = {
      ["l"] = {
        add = function()
          local clipboard = vim.fn.getreg("+"):gsub("\n", "")
          return {
            { "[" },
            { "](" .. clipboard .. ")" },
          }
        end,
        find = "%b[]%b()",
        delete = "^(%[)().-(%]%b())()$",
        change = {
          target = "^()()%b[]%((.-)()%)$",
          replacement = function()
            local clipboard = vim.fn.getreg("+"):gsub("\n", "")
            return {
              { "" },
              { clipboard },
            }
          end,
        },
      },
    }

    for k, _ in pairs(opts.keymaps) do
      opts.keymaps[k] = opts.keymaps[k] .. (k:match("line$") and surround_line or surround_char):rep(k:match("cur") and 2 or 1)
    end

    return opts
  end,
}
