---@type LazySpec
return {
  {
    "HakonHarnes/img-clip.nvim",
    cmd = { "PasteImage", "ImgClipConfig" },
    opts = { default = { dir_path = function() return vim.fs.joinpath(vim.fn.expand "%:p:h", ".images/img_clip") end } },
    specs = {
      "AstroNvim/astrocore",
      opts = function()
        local map = require("utils").keymap.set
        map.n {
          ["<Leader>P"] = { "<Cmd> PasteImage <CR>", desc = "[img-clip] Paste Image" },
          ["<Leader>fP"] = {
            function()
              local telescope = require "telescope.builtin"
              local actions = require "telescope.actions"
              local action_state = require "telescope.actions.state"

              local cwd = vim.uv.cwd()

              telescope.find_files {
                cwd = cwd,
                prompt_title = "Select Image",
                attach_mappings = function(_, map)
                  local function embed_image(prompt_bufnr)
                    local entry = action_state.get_selected_entry()
                    local filepath = entry[1]
                    actions.close(prompt_bufnr)

                    local img_clip = require "img-clip"
                    img_clip.paste_image(nil, string.format("%s/%s", cwd, filepath))
                  end

                  map("i", "<CR>", embed_image)
                  map("n", "<CR>", embed_image)

                  return true
                end,
              }
            end,
            desc = "[telescope] Find image and Paste",
          },
        }
      end,
    },
  },
  {
    "mistricky/codesnap.nvim",
    build = "make build_generator",
    cmd = { "CodeSnap", "CodeSnapSave", "CodeSnapHighlight", "CodeSnapSaveHighlight" },
    opts = {
      save_path = vim.env.HOME .. "/.images/codesnap",
      has_breadcrumbs = true,
      show_workspace = true,

      has_line_number = false,
      watermark = "NeoVim",
      bg_x_padding = 10,
      bg_y_padding = 80,
      bg_padding = 0, -- if 0, cancel padding
    },
    specs = {
      "AstroNvim/astrocore",
      opts = function()
        local map, swap = require("utils").keymap.set, require("utils").keymap.swap

        swap.n { ["<Leader>x"] = "<Leader>c" }
        map.v {
          ["<Leader>c"] = { desc = " CodeSnap" },
          ["<Leader>cs"] = { ":'<,'>CodeSnap<CR>", desc = "CodeSnap (clipboard)", silent = true },
          ["<Leader>cS"] = { ":'<,'>CodeSnapSave<CR>", desc = "CodeSnap (save)", silent = true },
          ["<Leader>ch"] = {
            ":'<,'>CodeSnapHighlight<CR>",
            desc = "CodeSnap with highlight (clipboard)",
            silent = true,
          },
          ["<Leader>cH"] = { ":'<,'>CodeSnapSaveHighlight<CR>", desc = "CodeSnap with highlight (save)", silent = true },
        }
      end,
    },
  },
  {
    "AstroNvim/astrocore",
    opts = {
      commands = {
        -- 使用image_snip 脚本在archlinux中进行截屏
        ScreenShot = {
          function(args)
            local cmd = { "image_snip" }

            if vim.bo.filetype == "markdown" then
              local filedir = vim.fs.joinpath(vim.fn.expand "%:p:h", ".images/screenshot")
              local fileprefix = vim.fn.expand "%:p:t:r"
              table.insert(cmd, string.format("--dir=%s", filedir))
              table.insert(cmd, string.format("--prefix=%s", fileprefix))
            end

            -- { code = 0, signal = 0, stdout = 'hello', stderr = '' }
            local result = vim.system(vim.list_extend(cmd, args.fargs), { text = true }):wait()

            if result.code == 0 then
              local image_path = result.stdout
              require("img-clip").paste_image(nil, image_path)
            end
          end,
          desc = "create a snip",
          nargs = "*",
          complete = function(arg, cmd, pos)
            local options = { "dir=", "name=", "ext=", "prefix=", "clipboard", "trim" }
            local used_options, unused_options = {}, nil
            for w in string.gmatch(cmd, "%-%-(%a+[%=]?)") do
              table.insert(used_options, w)
            end
            unused_options = vim.tbl_filter(
              function(value) return not vim.list_contains(used_options, value) end,
              options
            )
            if not vim.list_contains(options, string.match(arg, "^%-%-(%a+[%=]?)")) then
              return vim.tbl_map(function(value) return "--" .. value end, unused_options)
            end
          end,
        },
      },
    },
  },
}
