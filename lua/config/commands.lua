local autocmd = vim.api.nvim_create_autocmd
local command = vim.api.nvim_create_user_command

do
  local tmux_is_last_pane = false
  autocmd("WinEnter", {
    callback = function()
      tmux_is_last_pane = false
    end,
  })

  local function tmux_status(status_format)
    return vim.fn.system(("tmux display -pF '%s'"):format(status_format))
  end

  ---@param dir "h"|"j"|"k"|"l"|"p"
  ---@param opts? {follow_zoomed?:boolean}
  local function navigate(dir, opts)
    opts = opts or {}
    opts.follow_zoomed = vim.F.if_nil(opts.follow_zoomed, false)
    local is_tmux = vim.env.TMUX
    local winnr = vim.api.nvim_get_current_win()
    if not (dir == "p" and (is_tmux and tmux_is_last_pane and tmux_status("#{window_panes}") - 1 > 0)) then
      vim.cmd("wincmd " .. dir)
    end
    if is_tmux and winnr == vim.api.nvim_get_current_win() then
      local direction = ({
        h = "pane_at_left",
        j = "pane_at_bottom",
        k = "pane_at_top",
        l = "pane_at_right",
        p = ">:#{window_panes,1}",
      })[dir]
      local flag = ({ h = "L", j = "D", k = "U", l = "R", p = "l" })[dir]
      if opts.follow_zoomed then
        vim.fn.system(("tmux selectp -Z%s"):format(flag))
      else
        vim.fn.system(("tmux if -F '#{%s}' '' 'selectp -Z%s'"):format(direction, flag))
      end
      tmux_is_last_pane = true
    end
  end

  command("TmuxNavigate", function(args)
    local direction = args.fargs[1]
    local opts = {}
    for k, v in args.args:gmatch("([%w_]*)=([%w_]*)") do
      opts[k] = v
    end
    navigate(direction, opts)
  end, {
    desc = "Tmux Navigate",
    nargs = "+",
    complete = function()
      return { "h", "j", "k", "l", "p" }
    end,
  })
end
