return {
  {
    "michaelb/sniprun",
    dependencies = {
      {
        "AstroNvim/astrocore",
        opts = {
          mappings = {
            n = {
              ["<Leader>sr"] = { "<Cmd>SnipReset<CR>", desc = "Stop run select code" },
              ["<Leader>sc"] = { "<Cmd>SnipClose<CR>", desc = "Clear virtual text or others" },
              ["<Leader>sl"] = { "<Cmd>SnipRun<CR>", desc = "Run current line code" },
            },
            x = {
              ["<Leader>r"] = { ":SnipRun<CR>", desc = "Run select code", silent = true },
            },
          },
        },
      },
    },
    opts = {
      display = {
        "Classic", --# display results in the command-line  area
        "VirtualTextOk", --# display ok results as virtual text (multiline is shortened)
        "LongTempFloatingWindow", --# same as above, but only long results. To use with VirtualText[Ok/Err]

        -- "VirtualText",             --# display results as virtual text
        -- "TempFloatingWindow",      --# display results in a floating window
        -- "LongTempFloatingWindow",  --# same as above, but only long results. To use with VirtualText[Ok/Err]
        -- "Terminal",                --# display results in a vertical split
        -- "TerminalWithCode",        --# display results and code history in a vertical split
        -- "NvimNotify",              --# display with the nvim-notify plugin
        -- "Api"                      --# return output to a programming interface
      },
    },
    build = "sh ./install.sh 1",
    cmd = { "SnipRun", "SnipReset", "SnipClose", "SnipLive" },
  },
}
