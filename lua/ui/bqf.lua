return {
  "kevinhwang91/nvim-bqf",
  ft = "qf",
  opts = function()
    local fn = vim.fn

    function _G.qftf(info)
      local items
      local ret = {}

      if info.quickfix == 1 then
        items = fn.getqflist({ id = info.id, items = 0 }).items
      else
        items = fn.getloclist(info.winid, { id = info.id, items = 0 }).items
      end
      local limit = 30
      local fnameFmt1, fnameFmt2 = "%-" .. limit .. "s", "…%." .. (limit - 1) .. "s"
      local validFmt = "%s │%5d:%-3d│%s %s"
      for i = info.start_idx, info.end_idx do
        local e = items[i]
        local fname = ""
        local str
        if e.valid == 1 then
          if e.bufnr > 0 then
            fname = fn.bufname(e.bufnr)
            if fname == "" then
              fname = "[No Name]"
            else
              fname = fname:gsub("^" .. vim.env.HOME, "~")
            end
            -- char in fname may occur more than 1 width, ignore this issue in order to keep performance
            if #fname <= limit then
              fname = fnameFmt1:format(fname)
            else
              fname = fnameFmt2:format(fname:sub(1 - limit))
            end
          end
          local lnum = e.lnum > 99999 and -1 or e.lnum
          local col = e.col > 999 and -1 or e.col
          local qtype = e.type == "" and "" or " " .. e.type:sub(1, 1):upper()
          str = validFmt:format(fname, lnum, col, qtype, e.text)
        else
          str = e.text
        end
        table.insert(ret, str)
      end
      return ret
    end

    vim.o.qftf = "{info -> v:lua._G.qftf(info)}"

    return {
      auto_enable = true,
      auto_resize_height = true, -- highly recommended enable
      preview = {
        auto_preview = true,
        win_height = 12,
        win_vheight = 12,
        border = { "┏", "━", "┓", "┃", "┛", "━", "┗", "┃" },
        show_title = true,
        should_preview_cb = function(bufnr, qwinid)
          local ret = true
          local bufname = vim.api.nvim_buf_get_name(bufnr)
          local fsize = vim.fn.getfsize(bufname)
          if fsize > 100 * 1024 then
            -- skip file size greater than 100k
            ret = false
          elseif bufname:match "^fugitive://" then
            -- skip fugitive buffer
            ret = false
          end
          return ret
        end,
      },
      -- make `drop` and `tab drop` to become preferred
      func_map = {
        drop = "o",
        openc = "O",
        split = "<C-s>",
        tabb = "t",
        tabdrop = "<C-t>",
      },
      filter = {
        fzf = {
          action_for = {
            ["ctrl-s"] = "split",
            ["ctrl-x"] = "signtoggle",
          },
          extra_opts = { "--delimiter", "│" },
        },
      },
    }
  end,
  dependencies = {
    "junegunn/fzf",
    {
      "AstroNvim/astrocore",
      ---@param opts AstroCoreOpts
      opts = function(_, opts)
        opts.signs.BqfSign = { text = " " .. require("astroui").get_icon "Selected", texthl = "BqfSign" }
      end,
    },
  },
}
