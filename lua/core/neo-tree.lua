local function context_dir(state)
  -- return the directory of the current neo-tree node
  local node = state.tree:get_node()
  return node.type == "directory" and node:get_id() or node:get_parent_id()
end

local map_dirEntry = {}
---@type LazyPluginSpec
return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = function(_, opts)
    local user_opts = {
      close_if_last_window = true, -- Close Neo-tree if it is the last window left in the tab
      filesystem = {
        filtered_items = {
          visible = false, -- when true, they will just be displayed differently than normal items
          hide_dotfiles = true,
          hide_gitignored = true,
          hide_by_name = { "node_modules" },
          hide_by_pattern = { -- uses glob style patterns
            --"*.meta",
            --"*/src/*/tsconfig.json",
          },
          always_show = { -- remains visible even if other settings would normally hide it
            ".gitignore",
            ".zshrc",
            ".zshenv",
          },
          never_show = { ".git", ".bkt" },
          never_show_by_pattern = { -- uses glob style patterns
            ".null-ls_*",
          },
        },
      },
    }

    local user_mappings = {
      commands = {
        open_and_close = function(state)
          state.commands.open(state)
          require("neo-tree.command").execute { action = "close" }
        end,
        parent_or_close = function(state)
          local node = state.tree:get_node()
          if node:has_children() and node:is_expanded() then
            state.commands.toggle_node(state)
          else
            require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
            -- push map_dirEntry
            map_dirEntry[node:get_parent_id()] = node:get_id()
          end
        end,
        child_or_open = function(state)
          local node = state.tree:get_node()
          if node.type == "directory" or node:has_children() then
            if not node:is_expanded() then -- if unexpanded, expand
              state.commands.toggle_node(state)
            else -- if expanded and has children, seleect the next child
              if map_dirEntry[node:get_id()] then
                -- pop map_dirEntry
                require("neo-tree.ui.renderer").focus_node(state, map_dirEntry[node:get_id()])
              else
                require("neo-tree.ui.renderer").focus_node(state, node:get_child_ids()[1])
              end
            end
          else -- if not a directory just open it
            local preview = require "neo-tree.sources.common.preview"
            if preview.is_active() then
              preview.focus()
            else
              state.commands.open(state)
            end
          end
        end,
        find_files = function(state) require("telescope.builtin").find_files { cwd = context_dir(state) } end,
        live_grep = function(state)
          require("telescope").extensions.live_grep_args.live_grep_args { cwd = context_dir(state) }
        end,
        my_set_root = function(state)
          local fs = require "neo-tree.sources.filesystem"
          local path = context_dir(state)
          if state.search_pattern then fs.reset_search(state, false) end
          fs._navigate_internal(state, path, nil, nil, false)
        end,
        focus_filesystem = function(state)
          require("neo-tree.command").execute {
            source = "filesystem",
            position = state.current_position,
            action = "focus",
          }
        end,
        focus_git = function(state)
          require("neo-tree.command").execute {
            source = "git_status",
            position = state.current_position,
            action = "focus",
          }
        end,
        focus_buffers = function(state)
          require("neo-tree.command").execute {
            source = "buffers",
            position = state.current_position,
            action = "focus",
          }
        end,
      },
      window = {
        mappings = {
          -- disabled
          s = false,
          S = false,

          -- open or split
          ["<CR>"] = "open_and_close",
          ["<C-s>"] = "open_split",
          ["<C-v>"] = "open_vsplit",
          ["<C-t>"] = "open_tabnew",
          ["<C-w>"] = "open_with_window_picker",

          -- actions
          ["<C-f>"] = "find_files",
          ["<C-g>"] = "live_grep",

          -- set root
          ["."] = "my_set_root",

          -- focus
          e = "focus_filesystem",
          t = "focus_git",
          b = "focus_buffers",

          E = "toggle_auto_expand_width",
          o = { "show_help", nowait = false, config = { title = "Order by", prefix_key = "o" } },
        },
      },
      filesystem = {
        window = {
          mappings = {
            f = "fuzzy_sorter", -- 模糊匹配
            F = "fuzzy_sorter_directory",
            ["w"] = "navigate_up",
          },
        },
      },
      buffers = {
        window = {
          mappings = {
            ["bd"] = false,
            d = "buffer_delete",
          },
        },
      },
      git_status = {
        window = {
          mappings = {},
        },
      },
    }

    return require("astrocore").extend_tbl(opts, require("astrocore").extend_tbl(user_opts, user_mappings))
  end,
}
