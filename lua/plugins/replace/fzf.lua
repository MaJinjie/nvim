return {
  {
    "ibhagwan/fzf-lua",
    -- enabled = false,
    keys = {
      -- grep
      { "<leader>ss", function() require("fzf-lua").grep_project { cwd = vim.fn.expand("%:p:h") } end, desc = "rg ." },
      { "<leader>sg", function() require("fzf-lua").grep_project {} end,                               desc = "rg pwd" },
      { "<leader>sv", function() require("fzf-lua").grep_visual {} end,                                desc = "rg visual" },
      { "<leader>sl", function() require("fzf-lua").grep_last {} end,                                  desc = "rg last" },
      { "<leader>sb", function() require("fzf-lua").grep_curbuf {} end,                                desc = "rg curbuf" },
      -- files
      { "<leader>ff", function() require("fzf-lua").files { cwd = vim.fn.expand("%:p:h"), } end,       desc = "fd ." },
      {
        "<leader>fd",
        function()
          require("fzf-lua").files {
            fd_opts = "--color=always --hidden --follow --max-depth=6 "
                .. "--size=-1M"
          }
        end,
        desc = "fd ."

      },
      { "<leader>fb", function() require("fzf-lua").buffers {} end,      desc = "fd bufs" },
      { "<leader>fo", function() require("fzf-lua").oldfiles {} end,     desc = "fd oldfiles" },
      -- git
      { "<leader>gf", function() require("fzf-lua").git_files {} end,    desc = "fd gitfiles" },
      { "<leader>gb", function() require("fzf-lua").git_branches {} end, desc = "fd gitfiles" },
      { "<leader>gc", function() require("fzf-lua").git_commits() end,   desc = "fd gitfiles" },
      { "<leader>gs", function() require("fzf-lua").git_status {} end,   desc = "fd gitfiles" },
      -- jumps
      { "<leader>j",  function() require("fzf-lua").jumps() end,         desc = "jumps" },
      { "<leader>sh", function() require("fzf-lua").help_tags() end,     desc = "jumps" },
      { "<leader>tt", "<cmd> FzfLua <cr>" },
    },
    commander = {
      { cmd = function() require("fzf-lua").commands() end,         desc = "commands" },
      { cmd = function() require("fzf-lua").keymaps() end,          desc = "keymaps" },
      { cmd = function() require("fzf-lua").registers() end,        desc = "registers" },
      { cmd = function() require("fzf-lua").colorschemes() end,     desc = "colorschemes" },
      { cmd = function() require("fzf-lua").live_grep_native() end, desc = "lrg native" },
      { cmd = function() require("fzf-lua").live_grep_glob() end,   desc = "lrg glob" },
      { cmd = function() require("fzf-lua").live_grep_resume() end, desc = "lrg resume" },
      { cmd = function() require("fzf-lua").grep_cword() end,       desc = "rg lcword" },
      { cmd = function() require("fzf-lua").grep_cWORD() end,       desc = "rg ucWORD" },
      { cmd = function() require("fzf-lua").grep_visual() end,      desc = "rg visual" },
      { cmd = function() require("fzf-lua").grep_project() end,     desc = "rg project" },
    },
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons", },
    config = function()
      -- local commander = require("commander")
      -- commander.add({
      --
      -- }, {})
      local actions = require "fzf-lua.actions"
      require("fzf-lua").setup({
        -- fzf_bin = "fzf-tmux",
        --winopts
        winopts      = {
          border = { '┌', '─', '┐', '│', '┘', '─', '└', '│' },
          preview = {
            vertical   = "up:60%",
            horizontal = 'right:60%',
          },
        },
        -- files buffer
        buffers      = {
          ignore_current_buffer = true,
          height                = 20,
          width                 = 80,
          winopts               = {
            preview = {
              hidden = "hidden"
            }
          },

        },
        oldfiles     = {
          ignore_current_buffer = true,
          height                = 20,
          width                 = 80,
          winopts               = {
            preview = {
              hidden = "hidden"
            }
          },
        },
        files        = {
          winopts = {
            height = 20,
            width = 80,
            preview = {
              hidden = "hidden"
            },
            prompt = "Fzf❱ ",
            cwd_prompt = false,
            ignore_current_buffer = true,
          },
          fd_opts = "--color=always --hidden --follow --max-depth=4 "
              .. "--size=-1M"
        },
        -- grep
        grep         = {
          winopts      = {
            height = 0.9,
            width = 0.8,
            preview = {
              layout = "vertical",
            }
          },
          prompt       = "Fzf❱ ",
          input_prompt = "Rg❱ ",
          -- search = "",
          rg_opts      = "--column --line-number --no-heading "
              .. "--color=always --smart-case --max-columns=120 --max-depth=6 "
              .. "--hidden --follow --max-columns-preview --max-filesize 1M",
          rg_glob      = false,

        },
        -- autocmds
        autocmds     = {
          winopts = {
            height = 0.9,
            width = 0.8,
            preview = {
              layout = "vertical",
            }
          },
        },
        commands     = {
          winopts = {
            height = 0.9,
            width = 0.8,
            preview = {
              layout = "vertical",
            }
          },
        },
        keymaps      = {
          winopts = {
            height = 0.9,
            width = 0.8,
            preview = {
              layout = "vertical",
            }
          },
        },
        help_tags    = {
          winopts = {
            height = 0.9,
            width = 0.8,
            preview = {
              layout = "vertical",
            }
          },
        },
        registers    = {
          winopts = {
            height = 0.9,
            width = 0.8,
            preview = {
              layout = "vertical",
            }
          },
        },
        --git
        git_files    = {
          preview = {
            horizontal = "right:50%",
          }
        },
        git_branches = {
        },
        git_commits  = {
          winopts = {
            height = 0.9,
            width = 0.8,
            preview = {
              layout = "vertical",
            }
          },
        },
        git_bcommits = {
          winopts = {
            height = 0.9,
            width = 0.8,
            preview = {
              layout = "vertical",
            }
          },
        },
        git_tags     = {},
        git_stash    = {},
        git_status   = {
          winopts = {
            height = 0.9,
            width = 0.8,
            preview = {
              layout   = "vertical",
              vertical = "up:50%",
            }
          },
          fd_opts = "--color=always"
              .. "--size=-1M"
        },
        buffers      = {
          ignore_current_buffer = true,
          height                = 20,
          width                 = 80,
          winopts               = {
            preview = {
              hidden = "hidden"
            }
          },

        },
        jumps        = {
          winopts = {
            preview = {
              layout   = "vertical",
              vertical = "up:40%",
            }
          }

        },
        fzf_opts     = {
          ['--prompt'] = '❱ ',
          -- ["--border"] = "sharp",
          ["--marker"] = "▍",
          ["--info"] = "inline: ❰ ",
          ["--scrollbar"] = "█",
          ["--ellipsis"] = "  ",
          ["--cycle"] = true,
          ["--color"] =
          'hl:yellow:bold,hl+:yellow:reverse,bg+:-1,marker:#fe8019,spinner:#b8bb26,header:#cc241d,border:#808080',
        },
        --keybindings
        keymap       = {
          builtin = {
            ["<F1>"]     = "toggle-help",
            ["<F2>"]     = "toggle-fullscreen",
            -- Only valid with the 'builtin' previewer
            ["<F3>"]     = "toggle-preview-wrap",
            ["<F4>"]     = "toggle-preview",
            ["<F5>"]     = "toggle-preview-ccw",
            ["<F6>"]     = "toggle-preview-cw",
            ["<S-down>"] = "preview-page-down",
            ["<S-up>"]   = "preview-page-up",
            ["<S-left>"] = "preview-page-reset",
          },
          fzf = {
            ["enter"]      = "accept",
            ["ctrl-z"]     = "abort",
            ["ctrl-u"]     = "unix-line-discard",
            ["ctrl-f"]     = "half-page-down",
            ["ctrl-b"]     = "half-page-up",
            ["ctrl-a"]     = "beginning-of-line",
            ["ctrl-e"]     = "end-of-line",
            ["alt-a"]      = "toggle-all",
            -- Only valid with fzf previewers (bat/cat/git/etc)
            ["f3"]         = "toggle-preview-wrap",
            ["f4"]         = "toggle-preview",
            ["shift-down"] = "preview-page-down",
            ["shift-up"]   = "preview-page-up",
          },
        },
        actions      = {
          files = {
            ["default"] = actions.file_edit_or_qf,
            ["ctrl-s"]  = actions.file_split,
            ["ctrl-v"]  = actions.file_vsplit,
            ["ctrl-t"]  = actions.file_tabedit,
            ["alt-q"]   = actions.file_sel_to_qf,
            ["alt-l"]   = actions.file_sel_to_ll,
          },
          buffers = {
            ["default"] = actions.buf_edit,
            ["ctrl-s"]  = actions.buf_split,
            ["ctrl-v"]  = actions.buf_vsplit,
            ["ctrl-t"]  = actions.buf_tabedit,
          },
          grep = {
            ["default"] = actions.file_edit_or_qf,
            ["ctrl-s"]  = actions.file_split,
            ["ctrl-v"]  = actions.file_vsplit,
            ["ctrl-t"]  = actions.file_tabedit,
            ["alt-q"]   = actions.file_sel_to_qf,
            ["alt-l"]   = actions.file_sel_to_ll,
          },
        },


      })
    end
  }
}
