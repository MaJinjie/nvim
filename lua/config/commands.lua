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
  local function navigate(dir)
    local winnr = vim.api.nvim_get_current_win()
    if not (dir == "p" and tmux_is_last_pane and (vim.env.TMUX and tmux_status("#{window_panes}") - 1 > 0)) then
      vim.cmd("wincmd " .. dir)
    end
    if vim.env.TMUX and winnr == vim.api.nvim_get_current_win() then
      if dir == "p" then
        vim.fn.system("tmux selectp -l")
      else
        local directory = ({ h = "left", j = "bottom", k = "top", l = "right" })[dir]
        local flag = ({ h = "D", j = "D", k = "U", l = "R" })[dir]
        vim.fn.system(("tmux if -F '#{pane_at_%s}' '' 'selectp -Z%s'"):format(directory, flag))
      end
      tmux_is_last_pane = true
    end
  end

  command("TmuxNavigate", function(args)
    navigate(args.args)
  end, {
    desc = "Tmux Navigate",
    nargs = 1,
    complete = function()
      return { "h", "j", "k", "l", "p" }
    end,
  })
end
