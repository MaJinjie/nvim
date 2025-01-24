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
    if not (dir == "p" and tmux_is_last_pane and (is_tmux and tmux_status("#{window_panes}") - 1 > 0)) then
      vim.cmd("wincmd " .. dir)
    end
    if is_tmux and winnr == vim.api.nvim_get_current_win() then
      if dir == "p" then
        vim.fn.system("tmux selectp -l")
      else
        local direction = ({ h = "left", j = "bottom", k = "top", l = "right" })[dir]
        local flag = ({ h = "D", j = "D", k = "U", l = "R" })[dir]
        if opts.follow_zoomed then
          vim.fn.system(("tmux selectp -Z%s"):format(flag))
        else
          vim.fn.system(("tmux if -F '#{pane_at_%s}' '' 'selectp -Z%s'"):format(direction, flag))
        end
      end
      tmux_is_last_pane = true
    end
  end

  command("TmuxNavigate", function(args)
    navigate(args.args, { follow_zoomed = true })
  end, {
    desc = "Tmux Navigate",
    nargs = 1,
    complete = function()
      return { "h", "j", "k", "l", "p" }
    end,
  })
end
