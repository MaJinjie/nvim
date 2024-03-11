local t = require "telescope"

local M = {}

M.telescope = function()
  local actions = require "telescope.actions"
  local action_layout = require "telescope.actions.layout"
  return {
    defaults = {
      mappings = {
        i = {
          ["<esc>"] = function(bufnr)
            actions.close(bufnr)
          end,
          ["<C-\\>"] = action_layout.toggle_preview,
          ["<C-u>"] = function(bufnr)
            vim.api.nvim_feedkeys(
              vim.api.nvim_replace_termcodes(
                "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs> \
              <bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
                true,
                false,
                true
              ),
              "n",
              false
            )
          end,
          ["<C-s>"] = actions.select_horizontal,
        },
        n = {
          ["q"] = actions.close,
          ["<C-\\>"] = action_layout.toggle_preview,
        },
      },
      prompt_title = false,
      borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
    },
  }
end

M.zoxide = function()
  t.setup {
    extensions = {
      zoxide = {
        list_command = "zoxide query -ls",
        mappings = {
          ["<C-s>"] = { action = false },
          ["<C-v>"] = { action = false },
          ["<C-e>"] = { action = false },
          ["<C-t>"] = { action = false },
          default = {
            after_action = function(selection)
              vim.print("Update to (" .. selection.z_score .. ") " .. selection.path)
              vim.cmd("Telescope file_browser path=" .. selection.path)
            end,
          },
          ["<C-g>"] = {
            keepinsert = true,
            action = function(selection)
              require("fzf-lua").live_grep_glob { cwd = selection.path }
            end,
          },
          ["<C-f>"] = {
            keepinsert = true,
            action = function(selection)
              require("fzf-lua").files { cwd = selection.path }
            end,
          },
          ["<C-b>"] = {
            keepinsert = true,
            action = function(selection)
              vim.cmd("Telescope file_browser path=" .. selection.path)
            end,
          },
        },
      },
    },
  }
  t.load_extension "zoxide"
end

M.rualdi = function()
  t.setup {
    extensions = {
      rualdi = {
        prompt_title = "Rualdi", -- title of the prompt
        layout_strategy = "bottom_pane",
        layout_config = {
          height = 20,
        },
        command = function(selection)
          vim.cmd("Telescope file_browser path=" .. selection.path)
        end,
        live_grep = function(selection)
          require("fzf-lua").live_grep_glob { cwd = selection.path }
        end,
        find_files = function(selection)
          require("fzf-lua").files { cwd = selection.path }
        end,
        alias_hl = "Normal", -- highlight group for the alias
        path_hl = "Comment", -- highlight group for the path
      },
    },
  }
  t.load_extension "rualdi"
end

M.recent = function()
  require("telescope-all-recent").setup {
    database = {
      folder = vim.fn.stdpath "data",
      file = "telescope-all-recent.sqlite3",
      max_timestamps = 10,
    },
    debug = false,
    scoring = {
      recency_modifier = { -- also see telescope-frecency for these settings
        [1] = { age = 240, value = 100 }, -- past 4 hours
        [2] = { age = 1440, value = 80 }, -- past day
        [3] = { age = 4320, value = 60 }, -- past 3 days
        [4] = { age = 10080, value = 40 }, -- past week
        [5] = { age = 43200, value = 20 }, -- past month
        [6] = { age = 129600, value = 10 }, -- past 90 days
      },
      -- how much the score of a recent item will be improved.
      boost_factor = 0.0001,
    },
    default = {
      disable = true, -- disable any unkown pickers (recommended)
      use_cwd = true, -- differentiate scoring for each picker based on cwd
      sorting = "recent", -- sorting: options: 'recent' and 'frecency'
    },
    pickers = { -- allows you to overwrite the default settings for each picker
      man_pages = { -- enable man_pages picker. Disable cwd and use frecency sorting.
        disable = false,
        use_cwd = false,
        sorting = "frecency",
      },

      -- change settings for a telescope extension.
      -- To find out about extensions, you can use `print(vim.inspect(require'telescope'.extensions))`
      ["file_browser#file_browser"] = {
        disable = false,
        use_cwd = true,
        sorting = "frecency",
      },
      ["jvgrootveld/telescope-zoxide"] = {
        disable = false,
        use_cwd = false,
        sorting = "recent",
      },
      ["lmburns/telescope-rualdi.nvim"] = {
        disable = false,
        use_cwd = false,
        sorting = "frecency",
      },
    },
  }
end

M.file_browser = function()
  local fb_actions = require "telescope._extensions.file_browser.actions"
  local action_state = require "telescope.actions.state"
  t.setup {
    extensions = {
      file_browser = {
        -- path = vim.loop.cwd(),
        -- cwd = vim.loop.cwd(),
        cwd_to_path = true,
        layout_strategy = "bottom_pane",
        layout_config = {
          height = 20,
        },
        select_buffer = true,
        hidden = { file_browser = true, folder_browser = true },
        hide_parent_dir = true,
        prompt_path = false,
        quiet = true,
        hijack_netrw = true,
        use_ui_input = true,
        depth = 1,
        follow_symlinks = true,
        mappings = {
          ["i"] = {
            ["<C-e>"] = fb_actions.goto_home_dir,
            ["<C-u>"] = fb_actions.goto_cwd,
            ["<C-t>"] = fb_actions.toggle_browser,
            ["<C-.>"] = fb_actions.toggle_hidden,
            ["<C-g>"] = fb_actions.change_cwd,
            ["<A-a>"] = fb_actions.toggle_all,
            ["<bs>"] = function()
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<bs>", true, false, true), "n", false)
            end,
            ["<C-w>"] = function(prompt_bufnr, bypass)
              local current_picker = action_state.get_current_picker(prompt_bufnr)

              if current_picker:_get_prompt() == "" then
                fb_actions.goto_parent_dir(prompt_bufnr, bypass)
              else
                vim.api.nvim_feedkeys(
                  vim.api.nvim_replace_termcodes("<bs><bs><bs><bs><bs><bs>", true, false, true),
                  "n",
                  false
                )
              end
            end,
            ["/"] = fb_actions.open_dir,
          },
          ["n"] = {
            ["c"] = fb_actions.create,
            ["r"] = fb_actions.rename,
            ["m"] = fb_actions.move,
            ["y"] = fb_actions.copy,
            ["d"] = fb_actions.remove,

            ["h"] = fb_actions.goto_parent_dir,
            ["<C-w>"] = fb_actions.goto_parent_dir,
            ["l"] = fb_actions.open_dir,
            ["/"] = fb_actions.open_dir,

            ["e"] = fb_actions.goto_home_dir,
            ["u"] = fb_actions.goto_cwd,
            ["t"] = fb_actions.toggle_browser,
            ["."] = fb_actions.toggle_hidden,
            ["g"] = fb_actions.change_cwd,
            ["<A-a>"] = fb_actions.toggle_all,
          },
        },
      },
    },
  }
  t.load_extension "file_browser"
end

return M
