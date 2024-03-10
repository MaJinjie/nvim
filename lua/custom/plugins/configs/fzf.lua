return {
  winopts = {
    border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
    preview = {
      vertical = "up:60%",
      horizontal = "right:60%",
    },
  },
  -- files buffer
  buffers = {
    ignore_current_buffer = true,
    winopts = {
      height = 20,
      width = 80,
      preview = {
        hidden = "hidden",
      },
    },
  },
  oldfiles = {
    ignore_current_buffer = true,
    winopts = {
      height = 20,
      width = 80,
      preview = {
        hidden = "hidden",
      },
    },
  },
  files = {
    winopts = {
      height = 20,
      width = 80,
      preview = {
        hidden = "hidden",
      },
      prompt = "Fzf❱ ",
      cwd_prompt = false,
      ignore_current_buffer = true,
    },
    fd_opts = "--color=always --hidden --follow --max-depth=6 " .. "--size=-1M",
  },
  -- grep
  grep = {
    winopts = {
      height = 0.9,
      width = 0.8,
      preview = {
        layout = "vertical",
      },
    },
    prompt = "Fzf❱ ",
    input_prompt = "Rg❱ ",
    -- search = "",
    rg_opts = "--column --line-number --no-heading "
      .. "--color=always --smart-case --max-columns=120 --max-depth=6 "
      .. "--hidden --follow --max-columns-preview --max-filesize 1M",
    rg_glob = false,
  },
  -- autocmds commands keymaps help_tags registers
  autocmds = {
    winopts = {
      height = 0.9,
      width = 0.8,
      preview = {
        layout = "vertical",
      },
    },
  },
  commands = {
    winopts = {
      height = 0.9,
      width = 0.8,
      preview = {
        layout = "vertical",
      },
    },
  },
  keymaps = {
    winopts = {
      height = 0.9,
      width = 0.8,
      preview = {
        layout = "vertical",
      },
    },
    fzf_opts = { ["--query"] = "'" },
  },
  helptags = {
    winopts = {
      height = 0.9,
      width = 0.8,
      preview = {
        layout = "vertical",
      },
    },
  },
  registers = {
    winopts = {
      height = 0.9,
      width = 0.8,
      preview = {
        layout = "vertical",
      },
    },
  },
  manpages = {
    winopts = {
      height = 0.80,
      width = 0.70,
      preview = {
        layout = "horizontal",
        hidden = "hidden",
      },
    },
  },
  marks = {},
  spell_suggest = {},
  --git
  git = {
    files = {
      winopts = {
        preview = {
          horizontal = "right:50%",
        },
      },
    },
    branches = {},
    commits = {
      winopts = {
        height = 0.9,
        width = 0.8,
        preview = {
          layout = "vertical",
        },
      },
    },
    bcommits = {
      winopts = {
        height = 0.9,
        width = 0.8,
        preview = {
          layout = "vertical",
        },
      },
    },
    tags = {},
    stash = {},
    status = {
      winopts = {
        height = 0.9,
        width = 0.8,
        preview = {
          layout = "vertical",
          vertical = "up:50%",
        },
      },
    },
  },
  -- jumps changes
  jumps = {
    winopts = {
      preview = {
        layout = "vertical",
        vertical = "up:40%",
      },
    },
  },
  changes = {
    winopts = {
      preview = {
        layout = "vertical",
        vertical = "up:40%",
      },
    },
  },
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
