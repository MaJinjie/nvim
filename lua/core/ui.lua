return {
  {
    "rebelot/kanagawa.nvim",
    config = function()
      -- Default options:
      require("kanagawa").setup {
        compile = enable, -- enable compiling the colorscheme
      }

      require("kanagawa").load "wave"
    end,
  },
  {
    "rebelot/heirline.nvim",
    -- lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "nvim-lua/lsp-status.nvim",
      "SmiteshP/nvim-navic",
      "lewis6991/gitsigns.nvim",
    },
    config = function(_, opts)
      local conditions = require "heirline.conditions"
      local utils = require "heirline.utils"
      local hline = require "heirline"
      local colors = require("kanagawa.colors").setup() -- wink

      local ViMode = {
        -- get vim current mode, this information will be required by the provider
        -- and the highlight functions, so we compute it only once per component
        -- evaluation and store it as a component attribute
        init = function(self)
          self.mode = vim.fn.mode(1) -- :h mode()
        end,
        -- Now we define some dictionaries to map the output of mode() to the
        -- corresponding string and color. We can put these into `static` to compute
        -- them at initialisation time.
        static = {
          mode_names = { -- change the strings if you like it vvvvverbose!
            n = "N",
            no = "N?",
            nov = "N?",
            noV = "N?",
            ["no\22"] = "N?",
            niI = "Ni",
            niR = "Nr",
            niV = "Nv",
            nt = "Nt",
            v = "V",
            vs = "Vs",
            V = "V_",
            Vs = "Vs",
            ["\22"] = "^V",
            ["\22s"] = "^V",
            s = "S",
            S = "S_",
            ["\19"] = "^S",
            i = "I",
            ic = "Ic",
            ix = "Ix",
            R = "R",
            Rc = "Rc",
            Rx = "Rx",
            Rv = "Rv",
            Rvc = "Rv",
            Rvx = "Rv",
            c = "C",
            cv = "Ex",
            r = "...",
            rm = "M",
            ["r?"] = "?",
            ["!"] = "!",
            t = "T",
          },
          mode_colors = {
            n = "red",
            i = "green",
            v = "cyan",
            V = "cyan",
            ["\22"] = "cyan",
            c = "orange",
            s = "purple",
            S = "purple",
            ["\19"] = "purple",
            R = "orange",
            r = "orange",
            ["!"] = "red",
            t = "red",
          },
        },
        -- We can now access the value of mode() that, by now, would have been
        -- computed by `init()` and use it to index our strings dictionary.
        -- note how `static` fields become just regular attributes once the
        -- component is instantiated.
        -- To be extra meticulous, we can also add some vim statusline syntax to
        -- control the padding and make sure our string is always at least 2
        -- characters long. Plus a nice Icon.
        provider = function(self)
          return " %2(" .. self.mode_names[self.mode] .. "%)"
        end,
        -- Same goes for the highlight. Now the foreground will change according to the current mode.
        hl = function(self)
          local mode = self.mode:sub(1, 1) -- get only the first mode character
          return { fg = self.mode_colors[mode], bold = true }
        end,
        -- Re-evaluate the component only on ModeChanged event!
        -- Also allows the statusline to be re-evaluated when entering operator-pending mode
        update = {
          "ModeChanged",
          pattern = "*:*",
          callback = vim.schedule_wrap(function()
            vim.cmd "redrawstatus"
          end),
        },
      }

      local FileNameBlock = {
        -- let's first set up some attributes needed by this component and it's children
        init = function(self)
          self.filename = vim.api.nvim_buf_get_name(0)
        end,
      }
      -- We can now define some children separately and add them later

      local FileIcon = {
        init = function(self)
          local filename = self.filename
          local extension = vim.fn.fnamemodify(filename, ":e")
          self.icon, self.icon_color =
            require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
        end,
        provider = function(self)
          return self.icon and (self.icon .. " ")
        end,
        hl = function(self)
          return { fg = self.icon_color }
        end,
      }

      -- local FileName = {
      --   provider = function(self)
      --     -- first, trim the pattern relative to the current directory. For other
      --     -- options, see :h filename-modifers
      --     local filename = vim.fn.fnamemodify(self.filename, ":.")
      --     if filename == "" then
      --       return "[No Name]"
      --     end
      --     -- now, if the filename would occupy more than 1/4th of the available
      --     -- space, we trim the file path to its initials
      --     -- See Flexible Components section below for dynamic truncation
      --     if not conditions.width_percent_below(#filename, 0.25) then
      --       filename = vim.fn.pathshorten(filename)
      --     end
      --     return filename
      --   end,
      --   hl = { fg = utils.get_highlight("Directory").fg },
      -- }

      local FileFlags = {
        {
          condition = function()
            return vim.bo.modified
          end,
          provider = "[+]",
          hl = { fg = "green" },
        },
        {
          condition = function()
            return not vim.bo.modifiable or vim.bo.readonly
          end,
          provider = "",
          hl = { fg = "orange" },
        },
      }

      -- Now, let's say that we want the filename color to change if the buffer is
      -- modified. Of course, we could do that directly using the FileName.hl field,
      -- but we'll see how easy it is to alter existing components using a "modifier"
      -- component

      local FileNameModifer = {
        hl = function()
          if vim.bo.modified then
            -- use `force` because we need to override the child's hl foreground
            return { fg = "cyan", bold = true, force = true }
          end
        end,
      }

      -- let's add the children to our FileNameBlock component
      FileNameBlock = utils.insert(
        FileNameBlock,
        FileIcon,
        utils.insert(FileNameModifer, FileName), -- a new table where FileName is a child of FileNameModifier
        FileFlags,
        { provider = "%<" } -- this means that the statusline is cut here when there's not enough space
      )

      local FileType = {
        provider = function()
          return string.upper(vim.bo.filetype)
        end,
        hl = { fg = utils.get_highlight("Type").fg, bold = true },
      }
      local FileEncoding = {
        provider = function()
          local enc = (vim.bo.fenc ~= "" and vim.bo.fenc) or vim.o.enc -- :h 'enc'
          return enc ~= "utf-8" and enc:upper()
        end,
      }
      local FileFormat = {
        provider = function()
          local fmt = vim.bo.fileformat
          return fmt ~= "unix" and fmt:upper()
        end,
      }
      local FileSize = {
        provider = function()
          -- stackoverflow, compute human readable file size
          local suffix = { "b", "k", "M", "G", "T", "P", "E" }
          local fsize = vim.fn.getfsize(vim.api.nvim_buf_get_name(0))
          fsize = (fsize < 0 and 0) or fsize
          if fsize < 1024 then
            return fsize .. suffix[1]
          end
          local i = math.floor((math.log(fsize) / math.log(1024)))
          return string.format("%.2g%s", fsize / math.pow(1024, i), suffix[i + 1])
        end,
      }
      local FileLastModified = {
        -- did you know? Vim is full of functions!
        provider = function()
          local ftime = vim.fn.getftime(vim.api.nvim_buf_get_name(0))
          return (ftime > 0) and os.date("%c", ftime)
        end,
      }
      -- We're getting minimalists here!
      local Ruler = {
        -- %l = current line number
        -- %L = number of lines in the buffer
        -- %c = column number
        -- %P = percentage through file of displayed window
        provider = "%7(%l/%3L%):%2c %P",
      }
      -- I take no credits for this! :lion:
      local ScrollBar = {
        static = {
          sbar = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" },
          -- Another variant, because the more choice the better.
          -- sbar = { '🭶', '🭷', '🭸', '🭹', '🭺', '🭻' }
        },
        provider = function(self)
          local curr_line = vim.api.nvim_win_get_cursor(0)[1]
          local lines = vim.api.nvim_buf_line_count(0)
          local i = math.floor((curr_line - 1) / lines * #self.sbar) + 1
          return string.rep(self.sbar[i], 2)
        end,
        hl = { fg = "blue", bg = "bright_bg" },
      }

      local LSPActive = {
        condition = conditions.lsp_attached,
        update = { "LspAttach", "LspDetach" },

        -- You can keep it simple,
        -- provider = " [LSP]",

        -- Or complicate things a bit and get the servers names
        provider = function()
          local names = {}
          for i, server in pairs(vim.lsp.get_active_clients { bufnr = 0 }) do
            table.insert(names, server.name)
          end
          return " [" .. table.concat(names, " ") .. "]"
        end,
        hl = { fg = "green", bold = true },
      }
      -- I personally use it only to display progress messages!
      -- See lsp-status/README.md for configuration options.

      -- Note: check "j-hui/fidget.nvim" for a nice statusline-free alternative.
      local LSPMessages = {
        provider = require("lsp-status").status,
        hl = { fg = "gray" },
      }
      -- Awesome plugin

      -- The easy way.
      local Navic = {
        condition = function()
          return require("nvim-navic").is_available()
        end,
        provider = function()
          return require("nvim-navic").get_location { highlight = true }
        end,
        update = "CursorMoved",
      }

      -- Full nerd (with icon colors and clickable elements)!
      -- works in multi window, but does not support flexible components (yet ...)
      local Navic = {
        condition = function()
          return require("nvim-navic").is_available()
        end,
        static = {
          -- create a type highlight map
          type_hl = {
            File = "Directory",
            Module = "@include",
            Namespace = "@namespace",
            Package = "@include",
            Class = "@structure",
            Method = "@method",
            Property = "@property",
            Field = "@field",
            Constructor = "@constructor",
            Enum = "@field",
            Interface = "@type",
            Function = "@function",
            Variable = "@variable",
            Constant = "@constant",
            String = "@string",
            Number = "@number",
            Boolean = "@boolean",
            Array = "@field",
            Object = "@type",
            Key = "@keyword",
            Null = "@comment",
            EnumMember = "@field",
            Struct = "@structure",
            Event = "@keyword",
            Operator = "@operator",
            TypeParameter = "@type",
          },
          -- bit operation dark magic, see below...
          enc = function(line, col, winnr)
            return bit.bor(bit.lshift(line, 16), bit.lshift(col, 6), winnr)
          end,
          -- line: 16 bit (65535); col: 10 bit (1023); winnr: 6 bit (63)
          dec = function(c)
            local line = bit.rshift(c, 16)
            local col = bit.band(bit.rshift(c, 6), 1023)
            local winnr = bit.band(c, 63)
            return line, col, winnr
          end,
        },
        init = function(self)
          local data = require("nvim-navic").get_data() or {}
          local children = {}
          -- create a child for each level
          for i, d in ipairs(data) do
            -- encode line and column numbers into a single integer
            local pos = self.enc(d.scope.start.line, d.scope.start.character, self.winnr)
            local child = {
              {
                provider = d.icon,
                hl = self.type_hl[d.type],
              },
              {
                -- escape `%`s (elixir) and buggy default separators
                provider = d.name:gsub("%%", "%%%%"):gsub("%s*->%s*", ""),
                -- highlight icon only or location name as well
                -- hl = self.type_hl[d.type],

                on_click = {
                  -- pass the encoded position through minwid
                  minwid = pos,
                  callback = function(_, minwid)
                    -- decode
                    local line, col, winnr = self.dec(minwid)
                    vim.api.nvim_win_set_cursor(vim.fn.win_getid(winnr), { line, col })
                  end,
                  name = "heirline_navic",
                },
              },
            }
            -- add a separator only if needed
            if #data > 1 and i < #data then
              table.insert(child, {
                provider = " > ",
                hl = { fg = "bright_fg" },
              })
            end
            table.insert(children, child)
          end
          -- instantiate the new child, overwriting the previous one
          self.child = self:new(children, 1)
        end,
        -- evaluate the children containing navic components
        provider = function(self)
          return self.child:eval()
        end,
        hl = { fg = "gray" },
        update = "CursorMoved",
      }
      local Diagnostics = {

        condition = conditions.has_diagnostics,

        static = {
          error_icon = vim.fn.sign_getdefined("DiagnosticSignError")[1].text,
          warn_icon = vim.fn.sign_getdefined("DiagnosticSignWarn")[1].text,
          info_icon = vim.fn.sign_getdefined("DiagnosticSignInfo")[1].text,
          hint_icon = vim.fn.sign_getdefined("DiagnosticSignHint")[1].text,
        },

        init = function(self)
          self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
          self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
          self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
          self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
        end,

        update = { "DiagnosticChanged", "BufEnter" },

        {
          provider = "![",
        },
        {
          provider = function(self)
            -- 0 is just another output, we can decide to print it or not!
            return self.errors > 0 and (self.error_icon .. self.errors .. " ")
          end,
          hl = { fg = "diag_error" },
        },
        {
          provider = function(self)
            return self.warnings > 0 and (self.warn_icon .. self.warnings .. " ")
          end,
          hl = { fg = "diag_warn" },
        },
        {
          provider = function(self)
            return self.info > 0 and (self.info_icon .. self.info .. " ")
          end,
          hl = { fg = "diag_info" },
        },
        {
          provider = function(self)
            return self.hints > 0 and (self.hint_icon .. self.hints)
          end,
          hl = { fg = "diag_hint" },
        },
        {
          provider = "]",
        },
      }
      -- NOTE 可替换
      -- Diagnostics = utils.surround({ "![", "]" }, nil, Diagnostics)
      local Git = {
        condition = conditions.is_git_repo,

        init = function(self)
          self.status_dict = vim.b.gitsigns_status_dict
          self.has_changes = self.status_dict.added ~= 0
            or self.status_dict.removed ~= 0
            or self.status_dict.changed ~= 0
        end,

        hl = { fg = "orange" },

        { -- git branch name
          provider = function(self)
            return " " .. self.status_dict.head
          end,
          hl = { bold = true },
        },
        -- You could handle delimiters, icons and counts similar to Diagnostics
        {
          condition = function(self)
            return self.has_changes
          end,
          provider = "(",
        },
        {
          provider = function(self)
            local count = self.status_dict.added or 0
            return count > 0 and ("+" .. count)
          end,
          hl = { fg = "git_add" },
        },
        {
          provider = function(self)
            local count = self.status_dict.removed or 0
            return count > 0 and ("-" .. count)
          end,
          hl = { fg = "git_del" },
        },
        {
          provider = function(self)
            local count = self.status_dict.changed or 0
            return count > 0 and ("~" .. count)
          end,
          hl = { fg = "git_change" },
        },
        {
          condition = function(self)
            return self.has_changes
          end,
          provider = ")",
        },
      }
      -- 调试
      local DAPMessages = {
        condition = function()
          local session = require("dap").session()
          return session ~= nil
        end,
        provider = function()
          return " " .. require("dap").status()
        end,
        hl = "Debug",
        -- see Click-it! section for clickable actions
      }
      local UltTest = {
        condition = function()
          return vim.api.nvim_call_function("ultest#is_test_file", {}) ~= 0
        end,
        static = {
          passed_icon = vim.fn.sign_getdefined("test_pass")[1].text,
          failed_icon = vim.fn.sign_getdefined("test_fail")[1].text,
          passed_hl = { fg = utils.get_highlight("UltestPass").fg },
          failed_hl = { fg = utils.get_highlight("UltestFail").fg },
        },
        init = function(self)
          self.status = vim.api.nvim_call_function("ultest#status", {})
        end,

        -- again, if you'd like icons and numbers to be colored differently,
        -- just split the component in two
        {
          provider = function(self)
            return self.passed_icon .. self.status.passed .. " "
          end,
          hl = function(self)
            return self.passed_hl
          end,
        },
        {
          provider = function(self)
            return self.failed_icon .. self.status.failed .. " "
          end,
          hl = function(self)
            return self.failed_hl
          end,
        },
        {
          provider = function(self)
            return "of " .. self.status.tests - 1
          end,
        },
      }
      -- local WorkDir = {
      --   provider = function()
      --     local icon = (vim.fn.haslocaldir(0) == 1 and "l" or "g") .. " " .. " "
      --     local cwd = vim.fn.getcwd(0)
      --     cwd = vim.fn.fnamemodify(cwd, ":~")
      --     if not conditions.width_percent_below(#cwd, 0.25) then
      --       cwd = vim.fn.pathshorten(cwd)
      --     end
      --     local trail = cwd:sub(-1) == "/" and "" or "/"
      --     return icon .. cwd .. trail
      --   end,
      --   hl = { fg = "blue", bold = true },
      -- }
      local TerminalName = {
        -- we could add a condition to check that buftype == 'terminal'
        -- or we could do that later (see #conditional-statuslines below)
        provider = function()
          local tname, _ = vim.api.nvim_buf_get_name(0):gsub(".*:", "")
          return " " .. tname
        end,
        hl = { fg = "blue", bold = true },
      }
      local HelpFileName = {
        condition = function()
          return vim.bo.filetype == "help"
        end,
        provider = function()
          local filename = vim.api.nvim_buf_get_name(0)
          return vim.fn.fnamemodify(filename, ":t")
        end,
        hl = { fg = colors.blue },
      }
      -- set self Snippets
      local Snippets = {
        -- check that we are in insert or select mode
        condition = function()
          return vim.tbl_contains({ "s", "i" }, vim.fn.mode())
        end,
        provider = function()
          local forward = (vim.fn["luasnip#expand_or_jumpable"]() == 1) and "" or ""
          local backward = (vim.fn["luasnip#expand_or_jumpable"]() == 1) and " " or ""
          return backward .. forward
        end,
        hl = { fg = "red", bold = true },
      }
      local Spell = {
        condition = function()
          return vim.wo.spell
        end,
        provider = "SPELL ",
        hl = { bold = true, fg = "orange" },
      }

      --------------------------------------------------cmdline ------------------------------------------------------
      local SearchCount = {
        condition = function()
          return vim.v.hlsearch ~= 0 and vim.o.cmdheight == 0
        end,
        init = function(self)
          local ok, search = pcall(vim.fn.searchcount)
          if ok and search.total then
            self.search = search
          end
        end,
        provider = function(self)
          local search = self.search
          return string.format("[%d/%d]", search.current, math.min(search.total, search.maxcount))
        end,
      }
      local MacroRec = {
        condition = function()
          return vim.fn.reg_recording() ~= "" and vim.o.cmdheight == 0
        end,
        provider = " ",
        hl = { fg = "orange", bold = true },
        utils.surround({ "[", "]" }, nil, {
          provider = function()
            return vim.fn.reg_recording()
          end,
          hl = { fg = "green", bold = true },
        }),
        update = {
          "RecordingEnter",
          "RecordingLeave",
        },
      }
      vim.opt.showcmdloc = "statusline"
      local ShowCmd = {
        condition = function()
          return vim.o.cmdheight == 0
        end,
        provider = ":%3.5(%S%)",
      }

      local WorkDir = {
        init = function(self)
          self.icon = (vim.fn.haslocaldir(0) == 1 and "l" or "g") .. " " .. " "
          local cwd = vim.fn.getcwd(0)
          self.cwd = vim.fn.fnamemodify(cwd, ":~")
        end,
        hl = { fg = "blue", bold = true },

        flexible = 1,

        {
          -- evaluates to the full-lenth path
          provider = function(self)
            local trail = self.cwd:sub(-1) == "/" and "" or "/"
            return self.icon .. self.cwd .. trail .. " "
          end,
        },
        {
          -- evaluates to the shortened path
          provider = function(self)
            local cwd = vim.fn.pathshorten(self.cwd)
            local trail = self.cwd:sub(-1) == "/" and "" or "/"
            return self.icon .. cwd .. trail .. " "
          end,
        },
        {
          -- evaluates to "", hiding the component
          provider = "",
        },
      }
      local FileName = {
        init = function(self)
          self.lfilename = vim.fn.fnamemodify(self.filename, ":.")
          if self.lfilename == "" then
            self.lfilename = "[No Name]"
          end
        end,
        hl = { fg = utils.get_highlight("Directory").fg },

        flexible = 2,

        {
          provider = function(self)
            return self.lfilename
          end,
        },
        {
          provider = function(self)
            return vim.fn.pathshorten(self.lfilename)
          end,
        },
      }
      local Navic = { flexible = 3, Navic, { provider = "" } }

      ---------------------------------------------------------statusline

      local Align = { provider = "%=" }
      local Space = { provider = " " }

      ViMode = utils.surround({ "", "" }, "bright_bg", { ViMode, Snippets })

      local DefaultStatusline = {
        ViMode,
        Space,
        -- FileNameBlock,
        -- Space,
        WorkDir,
        Space,
        FileName,
        Space,
        Git,
        Space,
        Diagnostics,
        Align,
        Navic,
        DAPMessages,
        Align,
        LSPActive,
        Space,
        LSPMessages,
        Space,
        -- UltTest,
        -- Space,
        FileType,
        Space,
        Ruler,
        Space,
        ScrollBar,
      }

      local InactiveStatusline = {
        condition = conditions.is_not_active,
        FileType,
        Space,
        FileName,
        Align,
      }

      local SpecialStatusline = {
        condition = function()
          return conditions.buffer_matches {
            buftype = { "nofile", "prompt", "help", "quickfix" },
            filetype = { "^git.*", "fugitive" },
          }
        end,

        FileType,
        Space,
        HelpFileName,
        Align,
      }

      local TerminalStatusline = {

        condition = function()
          return conditions.buffer_matches { buftype = { "terminal" } }
        end,

        hl = { bg = "dark_red" },

        -- Quickly add a condition to the ViMode to only show it when buffer is active!
        { condition = conditions.is_active, ViMode, Space },
        FileType,
        Space,
        TerminalName,
        Align,
      }

      local StatusLines = {

        hl = function()
          if conditions.is_active() then
            return "StatusLine"
          else
            return "StatusLineNC"
          end
        end,

        -- the first statusline with no condition, or which condition returns true is used.
        -- think of it as a switch case with breaks to stop fallthrough.
        fallthrough = false,

        SpecialStatusline,
        TerminalStatusline,
        InactiveStatusline,
        DefaultStatusline,

        -- static = {
        --   mode_colors_map = {
        --     n = "red",
        --     i = "green",
        --     v = "cyan",
        --     V = "cyan",
        --     ["\22"] = "cyan",
        --     c = "orange",
        --     s = "purple",
        --     S = "purple",
        --     ["\19"] = "purple",
        --     R = "orange",
        --     r = "orange",
        --     ["!"] = "red",
        --     t = "green",
        --   },
        --   mode_color = function(self)
        --     local mode = conditions.is_active() and vim.fn.mode() or "n"
        --     return self.mode_colors_map[mode]
        --   end,
        -- },
      }

      ---------------------------------------------------------------------winbars
      local WinBars = {
        fallthrough = false,
        { -- A special winbar for terminals
          condition = function()
            return conditions.buffer_matches { buftype = { "terminal" } }
          end,
          utils.surround({ "", "" }, "dark_red", {
            FileType,
            Space,
            TerminalName,
          }),
        },
        { -- An inactive winbar for regular files
          condition = function()
            return not conditions.is_active()
          end,
          utils.surround({ "", "" }, "bright_bg", { hl = { fg = "gray", force = true }, FileNameBlock }),
        },
        -- A winbar for regular files
        utils.surround({ "", "" }, "bright_bg", FileNameBlock),
      }

      --------------------------------------------------------------------Tabline
      local TablineBufnr = {
        provider = function(self)
          return tostring(self.bufnr) .. ". "
        end,
        hl = "Comment",
      }

      -- we redefine the filename component, as we probably only want the tail and not the relative path
      local TablineFileName = {
        provider = function(self)
          -- self.filename will be defined later, just keep looking at the example!
          local filename = self.filename
          filename = filename == "" and "[No Name]" or vim.fn.fnamemodify(filename, ":t")
          return filename
        end,
        hl = function(self)
          return { bold = self.is_active or self.is_visible, italic = true }
        end,
      }

      -- this looks exactly like the FileFlags component that we saw in
      -- #crash-course-part-ii-filename-and-friends, but we are indexing the bufnr explicitly
      -- also, we are adding a nice icon for terminal buffers.
      local TablineFileFlags = {
        {
          condition = function(self)
            return vim.api.nvim_get_option_value("modified", { buf = self.bufnr })
          end,
          provider = "[+]",
          hl = { fg = "green" },
        },
        {
          condition = function(self)
            return not vim.api.nvim_get_option_value("modifiable", { buf = self.bufnr })
              or vim.api.nvim_get_option_value("readonly", { buf = self.bufnr })
          end,
          provider = function(self)
            if vim.api.nvim_get_option_value("buftype", { buf = self.bufnr }) == "terminal" then
              return "  "
            else
              return ""
            end
          end,
          hl = { fg = "orange" },
        },
      }

      -- Here the filename block finally comes together
      local TablineFileNameBlock = {
        init = function(self)
          self.filename = vim.api.nvim_buf_get_name(self.bufnr)
        end,
        hl = function(self)
          if self.is_active then
            return "TabLineSel"
          -- why not?
          -- elseif not vim.api.nvim_buf_is_loaded(self.bufnr) then
          --     return { fg = "gray" }
          else
            return "TabLine"
          end
        end,
        on_click = {
          callback = function(_, minwid, _, button)
            if button == "m" then -- close on mouse middle click
              vim.schedule(function()
                vim.api.nvim_buf_delete(minwid, { force = false })
              end)
            else
              vim.api.nvim_win_set_buf(0, minwid)
            end
          end,
          minwid = function(self)
            return self.bufnr
          end,
          name = "heirline_tabline_buffer_callback",
        },
        TablineBufnr,
        FileIcon, -- turns out the version defined in #crash-course-part-ii-filename-and-friends can be reutilized as is here!
        TablineFileName,
        TablineFileFlags,
      }

      -- a nice "x" button to close the buffer
      local TablineCloseButton = {
        condition = function(self)
          return not vim.api.nvim_get_option_value("modified", { buf = self.bufnr })
        end,
        { provider = " " },
        {
          provider = "",
          hl = { fg = "gray" },
          on_click = {
            callback = function(_, minwid)
              vim.schedule(function()
                vim.api.nvim_buf_delete(minwid, { force = false })
                vim.cmd.redrawtabline()
              end)
            end,
            minwid = function(self)
              return self.bufnr
            end,
            name = "heirline_tabline_close_buffer_callback",
          },
        },
      }

      -- The final touch!
      local TablineBufferBlock = utils.surround({ "", "" }, function(self)
        if self.is_active then
          return utils.get_highlight("TabLineSel").bg
        else
          return utils.get_highlight("TabLine").bg
        end
      end, { TablineFileNameBlock, TablineCloseButton })

      -- this is the default function used to retrieve buffers
      local get_bufs = function()
        return vim.tbl_filter(function(bufnr)
          return vim.api.nvim_get_option_value("buflisted", { buf = bufnr })
        end, vim.api.nvim_list_bufs())
      end

      -- initialize the buflist cache
      local buflist_cache = {}

      -- setup an autocmd that updates the buflist_cache every time that buffers are added/removed
      vim.api.nvim_create_autocmd({ "VimEnter", "UIEnter", "BufAdd", "BufDelete" }, {
        callback = function()
          vim.schedule(function()
            local buffers = get_bufs()
            for i, v in ipairs(buffers) do
              buflist_cache[i] = v
            end
            for i = #buffers + 1, #buflist_cache do
              buflist_cache[i] = nil
            end

            -- check how many buffers we have and set showtabline accordingly
            if #buflist_cache > 1 then
              vim.o.showtabline = 2 -- always
            elseif vim.o.showtabline ~= 1 then -- don't reset the option if it's already at default value
              vim.o.showtabline = 1 -- only when #tabpages > 1
            end
          end)
        end,
      })

      local BufferLine = utils.make_buflist(
        TablineBufferBlock,
        { provider = " ", hl = { fg = "gray" } },
        { provider = " ", hl = { fg = "gray" } },
        -- out buf_func simply returns the buflist_cache
        function()
          return buflist_cache
        end,
        -- no cache, as we're handling everything ourselves
        false
      )

      local TablinePicker = {
        condition = function(self)
          return self._show_picker
        end,
        init = function(self)
          local bufname = vim.api.nvim_buf_get_name(self.bufnr)
          bufname = vim.fn.fnamemodify(bufname, ":t")
          local label = bufname:sub(1, 1)
          local i = 2
          while self._picker_labels[label] do
            if i > #bufname then
              break
            end
            label = bufname:sub(i, i)
            i = i + 1
          end
          self._picker_labels[label] = self.bufnr
          self.label = label
        end,
        provider = function(self)
          return self.label
        end,
        hl = { fg = "red", bold = true },
      }

      --keybinding
      vim.keymap.set("n", "gbp", function()
        local tabline = require("heirline").tabline
        local buflist = tabline._buflist[1]
        buflist._picker_labels = {}
        buflist._show_picker = true
        vim.cmd.redrawtabline()
        local char = vim.fn.getcharstr()
        local bufnr = buflist._picker_labels[char]
        if bufnr then
          vim.api.nvim_win_set_buf(0, bufnr)
        end
        buflist._show_picker = false
        vim.cmd.redrawtabline()
      end)

      local Tabpage = {
        provider = function(self)
          return "%" .. self.tabnr .. "T " .. self.tabpage .. " %T"
        end,
        hl = function(self)
          if not self.is_active then
            return "TabLine"
          else
            return "TabLineSel"
          end
        end,
      }

      local TabpageClose = {
        provider = "%999X  %X",
        hl = "TabLine",
      }

      local TabPages = {
        -- only show this component if there's 2 or more tabpages
        condition = function()
          return #vim.api.nvim_list_tabpages() >= 2
        end,
        { provider = "%=" },
        utils.make_tablist(Tabpage),
        TabpageClose,
      }

      local TabLineOffset = {
        condition = function(self)
          local win = vim.api.nvim_tabpage_list_wins(0)[1]
          local bufnr = vim.api.nvim_win_get_buf(win)
          self.winid = win

          if vim.bo[bufnr].filetype == "NvimTree" then
            self.title = "NvimTree"
            return true
            -- elseif vim.bo[bufnr].filetype == "TagBar" then
            --     ...
          end
        end,

        provider = function(self)
          local title = self.title
          local width = vim.api.nvim_win_get_width(self.winid)
          local pad = math.ceil((width - #title) / 2)
          return string.rep(" ", pad) .. title .. string.rep(" ", pad)
        end,

        hl = function(self)
          if vim.api.nvim_get_current_win() == self.winid then
            return "TablineSel"
          else
            return "Tabline"
          end
        end,
      }

      -- total
      local TabLine = { TabLineOffset, BufferLine, TabPages }
      require("heirline").setup {
        statusline = StatusLines,
        winbar = WinBars,
        tabline = TabLine,

        opts = {
          colors = colors,
          -- if the callback returns true, the winbar will be disabled for that window
          -- the args parameter corresponds to the table argument passed to autocommand callbacks. :h nvim_lua_create_autocmd()
          disable_winbar_cb = function(args)
            return conditions.buffer_matches({
              buftype = { "nofile", "prompt", "help", "quickfix" },
              filetype = { "^git.*", "fugitive", "Trouble", "dashboard" },
            }, args.buf)
          end,
        },
      }

      -- Yep, with heirline we're driving manual!
      vim.o.showtabline = 2
      vim.cmd [[au FileType * if index(['wipe', 'delete'], &bufhidden) >= 0 | set nobuflisted | endif]]
    end,
  },
}
