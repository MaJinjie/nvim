-- FrecencyValidate[!], FrecencyDelete [path],
return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          n = {
            ["<Leader>fc"] = {
              function() require("telescope-live-grep-args.shortcuts").grep_word_under_cursor() end,
              desc = "Find word under cursor",
            },
            ["<Leader>fw"] = {
              function() require("telescope").extensions.live_grep_args.live_grep_args() end,
              desc = "Find words",
            },
            ["<Leader>fW"] = {
              function()
                local vimgrep_arguments = require("telescope.config").values.vimgrep_arguments
                table.insert(vimgrep_arguments, "--hidden")
                table.insert(vimgrep_arguments, "--no-ignore")
                require("telescope").extensions.live_grep_args.live_grep_args {
                  vimgrep_arguments = vimgrep_arguments,
                }
              end,
              desc = "Find words in all files",
            },
            ["<Leader>fg"] = {
              require("telescope.builtin").git_files,
              desc = "Find workspace files",
            },
            ["<Leader>fo"] = {
              function() require("telescope").extensions.frecency.frecency {} end,
              desc = "Find history",
            },
            ["<Leader>fe"] = {
              function() require("telescope").extensions.file_browser.file_browser { path = vim.fn.expand "%:p:h" } end,
              desc = "",
            },
          },
          x = {
            ["<Leader>fc"] = {
              function() require("telescope-live-grep-args.shortcuts").grep_visual_selection() end,
              desc = "Find words in visual selection",
            },
          },
        },
      },
    },
    "nvim-telescope/telescope-live-grep-args.nvim",
    "nvim-telescope/telescope-frecency.nvim",
    "nvim-telescope/telescope-file-browser.nvim",
    "nvim-lua/plenary.nvim",
  },
  opts = function(_, opts)
    local telescope = require "telescope"
    local actions, state = require "telescope.actions", require "telescope.actions.state"
    local lga_actions = require "telescope-live-grep-args.actions"
    local fb_actions = require "telescope._extensions.file_browser.actions"

    local extenstions = {
      frecency = {
        workspaces = {
          ["conf"] = vim.fn.expand "$XDG_CONFIG_HOME",
          ["zsh"] = vim.fn.expand "$XDG_CONFIG_HOME/zsh",
          ["nvim"] = vim.fn.expand "$XDG_CONFIG_HOME/nvim",
          ["home"] = vim.fn.expand "$HOME",
          ["move"] = vim.fn.expand "$HOME/move",
        },
      },
      file_browser = {
        cwd_to_path = true,
        layout_strategy = "bottom_pane",
        hide_parent_dir = true,
        grouped = true,
        collapse_dirs = true,
        quiet = true,
        layout_config = { height = 20 },

        hidden = false,
        respect_gitignore = true,
        no_ignore = false,
        mappings = {
          i = {
            ["/"] = fb_actions.open_dir,
            ["<C-w>"] = fb_actions.goto_parent_dir,
            ["<C-t>"] = fb_actions.toggle_browser,
            ["<C-h>"] = fb_actions.toggle_hidden,
            ["<C-c>"] = fb_actions.change_cwd,
            ["<A-enter>"] = fb_actions.create_from_prompt,
          },
        },
      },
    }
    local user_opts = {
      defaults = {
        mappings = {
          i = {
            ["<Esc>"] = actions.close,
            ["<C-q>"] = actions.close,
            ["<C-u>"] = false,
            ["<C-s>"] = actions.select_horizontal,
            ["<C-v>"] = actions.select_vertical,
            ["<A-t>"] = actions.select_tab,
            ["<A-a>"] = actions.toggle_all,
            ["<A-s>"] = actions.send_selected_to_qflist + actions.open_qflist,
            ["<A-q>"] = actions.send_to_qflist + actions.open_qflist,
          },
        },
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--trim",
        },
      },
      pickers = {
        buffers = {
          mappings = {
            i = {
              ["<C-x>"] = actions.delete_buffer,
            },
          },
        },
      },
      extensions = extenstions,
    }
    return require("astrocore").extend_tbl(opts, user_opts)
  end,
}
