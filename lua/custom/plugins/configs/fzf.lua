local winopts = function()
  return {
    h = {
      width = vim.o.columns > 100 and 0.6 or 0.85,
      height = 20,
      preview = {
        hidden = "hidden",
        layout = "horizontal",
      },
    },
    v = {
      width = 0.8,
      height = 0.9,
      preview = {
        hidden = "nohidden",
        layout = "vertical",
      },
    },
  }
end
local winopts_fn = function(layout, opts)
  return function()
    return vim.tbl_deep_extend("force", winopts()[layout], opts or {})
  end
end

return {
  winopts = {
    border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
    preview = {
      vertical = "up:60%",
      horizontal = "right:60%",
    },
  },
  -- files buffer
  buffers = { ignore_current_buffer = true, winopts_fn = winopts_fn "h" },
  oldfiles = { ignore_current_buffer = true, winopts_fn = winopts_fn "h" },
  files = {
    winopts_fn = winopts_fn("h", {
      prompt = "Fzf❱ ",
      cwd_prompt = false,
      ignore_current_buffer = true,
    }),
    fd_opts = "--color=always --hidden --follow --max-depth=6 " .. "--size=-1M",
  },
  -- grep
  grep = {
    winopts_fn = winopts_fn "v",
    prompt = "Fzf❱ ",
    input_prompt = "Rg❱ ",
    -- search = "",
    rg_opts = "--column --line-number --no-heading "
      .. "--color=always --smart-case --max-columns=120 --max-depth=6 "
      .. "--hidden --follow --max-columns-preview --max-filesize 1M",
    rg_glob = true,
    glob_flag = "--iglob", -- for case sensitive globs use '--glob'
    glob_separator = "%s%-%-", -- query separator pattern (lua): ' --',
  },
  -- autocmds commands keymaps help_tags registers
  autocmds = { winopts_fn = winopts_fn "v" },
  commands = { winopts_fn = winopts_fn "v" },
  keymaps = { winopts_fn = winopts_fn "v", fzf_opts = { ["--query"] = "'" } },
  helptags = { winopts_fn = winopts_fn "v" },
  registers = { winopts_fn = winopts_fn "v" },
  manpages = { winopts_fn = winopts_fn("h", { height = 0.8, width = 0.7 }) },
  marks = {},
  spell_suggest = {},
  --git
  git = {
    files = { winopts = { preview = { horizontal = "right:50%" } } },
    branches = {},
    commits = { winopts_fn = winopts_fn "v" },
    bcommits = { winopts_fn = winopts_fn "v" },
    tags = {},
    stash = {},
    status = { winopts_fn = winopts_fn("v", { preview = { vertical = "up:60%" } }) },
  },
  -- jumps changes
  jumps = { winopts_fn = winopts_fn("v", { preview = { vertical = "up:40%" } }) },
  changes = { winopts_fn = winopts_fn("v", { preview = { vertical = "up:40%" } }) },
  fzf_opts = {
    ["--prompt"] = "❱ ",
    -- ["--border"] = "sharp",
    ["--marker"] = "▍",
    ["--info"] = "inline: ❰ ",
    ["--scrollbar"] = "█",
    ["--ellipsis"] = "  ",
    ["--cycle"] = true,
    ["--color"] = "hl:yellow:bold,hl+:yellow:reverse,bg+:-1,marker:#fe8019,spinner:#b8bb26,header:#cc241d,border:#808080",
  },
  --keybindings
  keymap = {
    builtin = {
      ["<F1>"] = "toggle-help",
      ["<F2>"] = "toggle-fullscreen",
      -- Only valid with the 'builtin' previewer
      ["<F3>"] = "toggle-preview-wrap",
      ["<F4>"] = "toggle-preview",
      ["<F5>"] = "toggle-preview-ccw",
      ["<F6>"] = "toggle-preview-cw",
      ["<S-down>"] = "preview-page-down",
      ["<S-up>"] = "preview-page-up",
      ["<S-left>"] = "preview-page-reset",
    },
    fzf = {
      ["enter"] = "accept",
      ["ctrl-z"] = "abort",
      ["ctrl-c"] = "abort",
      ["ctrl-u"] = "unix-line-discard",
      ["ctrl-d"] = "half-page-down",
      ["ctrl-f"] = "preview-half-page-down",
      ["ctrl-b"] = "beginning-of-line",
      ["ctrl-e"] = "end-of-line",
      ["alt-a"] = "toggle-all",
      -- Only valid with fzf previewers (bat/cat/git/etc)
      ["f3"] = "toggle-preview-wrap",
      ["f4"] = "toggle-preview",
      ["shift-down"] = "preview-page-down",
      ["shift-up"] = "preview-page-up",
    },
  },
}
