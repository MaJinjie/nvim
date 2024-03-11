local M = { actions = {} }

M.actions.nvimTreeFocusOrToggle = function()
  local currentBuf = vim.api.nvim_get_current_buf()
  local currentBufFt = vim.api.nvim_get_option_value("filetype", { buf = currentBuf })
  if currentBufFt == "NvimTree" then
    vim.cmd "NvimTreeToggle"
  else
    vim.cmd "NvimTreeFocus"
  end
end

-- 记录每一次离开目录时，所在节点的路径（不可以是节点的地址，节点可能会在离开时被销毁), 类比yazi
-- key value -> (parent_dir, filename)
local child_path_map = {}

M.options = {
  on_attach = function(bufnr)
    local api = require "nvim-tree.api"
    local lib = require "nvim-tree.lib"
    local actions = require "nvim-tree.actions"
    local utils = require "nvim-tree.utils"
    local renderer = require "nvim-tree.renderer"
    -- open as vsplit on current node
    local function vsplit()
      local node = api.tree.get_node_under_cursor()
      if node.nodes == nil then
        api.node.open.vertical()
        api.tree.close()
      end
    end
    local function split()
      local node = api.tree.get_node_under_cursor()
      if node.nodes == nil then
        api.node.open.horizontal()
        api.tree.close()
      end
    end
    local function edit_and_close()
      local node = api.tree.get_node_under_cursor()
      if node.nodes ~= nil then
        api.node.open.edit()
      else
        api.node.open.edit()
        api.tree.close()
      end
    end
    local function get_dir()
      local node = api.tree.get_node_under_cursor()
      local is_folder = node.fs_stat and node.fs_stat.type == "directory" or false
      return is_folder and node.absolute_path or vim.fn.fnamemodify(node.absolute_path, ":h")
    end

    local function change_root_to_node(cwd)
      return function()
        if cwd ~= nil then
          cwd = cwd == "_workspace_" and vim.fn.getcwd(-1, -1) or cwd
        else
          cwd = get_dir()
        end
        api.tree.change_root(cwd)
      end
    end
    local function change_cwd_to_root()
      vim.loop.chdir(api.tree.get_nodes().absolute_path)
    end

    local function change_root_and_cwd_to_node()
      change_root_to_node()()
      change_cwd_to_root()
    end

    local function fzf(func, opts)
      local ok, _ = pcall(require, "fzf-lua")
      if not ok then
        return
      end
      return function()
        local node = api.tree.get_node_under_cursor()
        local is_folder = node.fs_stat and node.fs_stat.type == "directory" or false
        opts = opts or {}
        opts.cwd = is_folder and node.absolute_path or vim.fn.fnamemodify(node.absolute_path, ":h")
        require("fzf-lua")[func](opts)
      end
    end

    local function record_file()
      local cursor_node = api.tree.get_node_under_cursor()
      local parent_dir = vim.fn.fnamemodify(cursor_node.absolute_path, ":h")
      child_path_map[parent_dir] = vim.fn.fnamemodify(cursor_node.absolute_path, ":t")
    end
    local function navigate_to_parent(b)
      return function()
        local cursor_node = api.tree.get_node_under_cursor()
        local parent_dir = vim.fn.fnamemodify(cursor_node.absolute_path, ":h")
        if parent_dir == "/" then
          return
        end
        child_path_map[parent_dir] = vim.fn.fnamemodify(cursor_node.absolute_path, ":t")

        if parent_dir == vim.loop.cwd() then
          api.tree.change_root(vim.fn.fnamemodify(parent_dir, ":h"))
        end
        api.node.navigate[(b and "parent_close" or "parent")]()
      end
    end

    local function navigate_to_child()
      -- l 1> to firlst child(dir > file) 2> open dir(nodes) 3> to first child ...

      local node = api.tree.get_node_under_cursor()

      local is_folder = node.fs_stat and node.fs_stat.type == "directory" or false

      if not is_folder then
        actions.node.open_file.fn("edit", node.absolute_path)
      else
        if not node.open then
          lib.expand_or_collapse(node)
          -- 如果打开后节点个数为0，就直接关闭
          if #node.nodes == 0 then
            node.open = false
            renderer.draw() -- close dir
          end
        end
        if child_path_map[node.absolute_path] then
          -- vim.print(child_path_map[node.absolute_path])
          utils.focus_file(node.absolute_path .. "/" .. child_path_map[node.absolute_path])
        else
          utils.focus_node_or_parent(node.nodes[1])
        end
      end
    end

    local function focus_zz()
      local cursor_node = api.tree.get_node_under_cursor()
      local nodes = cursor_node.parent.nodes
      local index = (#nodes % 2 == 1 and #nodes + 1 or #nodes) / 2
      utils.focus_node_or_parent(nodes[index])
    end

    local function opts(desc)
      return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    -- fs (yes)
    vim.keymap.set("n", "a", api.fs.create, opts "create")
    vim.keymap.set("n", "rr", api.fs.remove, opts "remove")
    vim.keymap.set("n", "rn", api.fs.rename, opts "rename name")
    vim.keymap.set("n", "rp", api.fs.rename_full, opts "rename path")

    vim.keymap.set("n", "cx", api.fs.cut, opts "cut")
    vim.keymap.set("n", "cc", api.fs.copy.node, opts "copy node")
    vim.keymap.set("n", "cn", api.fs.copy.filename, opts "copy filename")
    vim.keymap.set("n", "cp", api.fs.copy.absolute_path, opts "copy path")
    vim.keymap.set("n", "cy", api.fs.paste, opts "paste")

    -- mvoe
    vim.keymap.set("n", "l", navigate_to_child, opts "navigate to child")
    vim.keymap.set("n", "h", navigate_to_parent(true), opts "navigate to parent")
    vim.keymap.set("n", "k", function()
      api.node.navigate.sibling.prev()
    end, opts "sibling prev")
    vim.keymap.set("n", "j", function()
      local node = api.tree.get_node_under_cursor()
      if not node then
        vim.cmd "normal! j"
      else
        api.node.navigate.sibling.next()
      end
    end, opts "sibling next")
    -- vim.keymap.set("n", "L", navigate_to_child, opts "navigate to child")
    vim.keymap.set("n", "H", navigate_to_parent(false), opts "navigate to parent")
    vim.keymap.set("n", "K", function()
      record_file()
      api.node.navigate.parent()
      api.node.navigate.sibling.prev()
    end, opts "sibling prev")
    vim.keymap.set("n", "J", function()
      record_file()
      api.node.navigate.parent()
      api.node.navigate.sibling.next()
    end, opts "sibling next")

    vim.keymap.set("n", "zt", api.node.navigate.sibling.first, opts "sibling first")
    vim.keymap.set("n", "zb", api.node.navigate.sibling.last, opts "sibing last")
    vim.keymap.set("n", "zz", focus_zz, opts "sibing last")

    vim.keymap.set("n", "g?", api.tree.toggle_help, opts "Help")

    -- change dir
    vim.keymap.set("n", "dt", change_root_and_cwd_to_node, opts "change rootandcwd to node")
    vim.keymap.set("n", "dp", change_cwd_to_root, opts "change cwd to root")
    vim.keymap.set("n", "dd", change_cwd_to_root, opts "change cwd to root")
    vim.keymap.set("n", "dr", change_root_to_node(), opts "change root to node")
    vim.keymap.set("n", "dw", change_root_to_node "_workspace_", opts "change root to workspace")
    vim.keymap.set("n", "dc", change_root_to_node "~/.config/nvim/lua", opts "change root to nvim config")
    vim.keymap.set("n", "dh", change_root_to_node "~", opts "change root to ~")
    vim.keymap.set("n", "d/", change_root_to_node "/", opts "change root to /")

    vim.keymap.set("n", "df", fzf "files", opts "files")
    vim.keymap.set("n", "ds", fzf "live_grep_glob", opts "live_grep_glob")
    -- expand collapse
    vim.keymap.set("n", "-", function()
      api.tree.collapse_all(false)
    end, opts "Collapse All")
    vim.keymap.set("n", "=", api.tree.expand_all, opts "expand all")

    -- edit
    vim.keymap.set("n", "<C-s>", split, opts "split")
    vim.keymap.set("n", "<C-v>", vsplit, opts "vsplit")
    vim.keymap.set("n", "<CR>", edit_and_close, opts "Open In Place")

    vim.keymap.set("n", "i", api.node.show_info_popup, opts "Open info")
    vim.keymap.set("n", "p", api.node.open.preview_no_picker, opts "Open preview")
    vim.keymap.set("n", "q", api.tree.close, opts "close tree")

    --filter
    vim.keymap.set("n", "f", api.live_filter.start, opts "filter")
    vim.keymap.set("n", "F", api.live_filter.start, opts "filter clear")

    --events
    api.events.subscribe(api.events.Event.FileCreated, function(file)
      vim.cmd("edit " .. file.fname)
    end)
  end,
  sync_root_with_cwd = false,
  update_focused_file = {
    enable = false,
    update_root = false,
  },
  sort = {
    sorter = "modification_time",
  },
  filters = {
    git_ignored = true,
    custom = { "^.git$", "^.bkt$" },
    exclude = { "^.bkt$", "^.git$" },
  },
  live_filter = {
    prefix = "[FILTER]: ",
    always_show_folders = true,
  },
}
return M
