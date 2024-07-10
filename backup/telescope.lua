local function generate_path_display(opts)
  opts = opts or {}

  local is_highlights = vim.F.if_nil(opts.highlights, true)

  return function(_, path)
    local entry_count, os_sep = 3, "/"
    local file_pos, dir_pos

    for i = #path, 1, -1 do
      if os_sep == path:sub(i, i) then
        entry_count = entry_count - 1
        if not file_pos then file_pos = i + 1 end
        if entry_count == 0 then dir_pos = i + 1 end
      end
    end
    file_pos = file_pos or 1
    dir_pos = dir_pos or 1

    local highlights = {
      {
        {
          0,
          file_pos - dir_pos,
          -- #path - dir_pos + 1,
        },
        "Nontext", -- highlight group name
      },
    }
    return path:sub(dir_pos), is_highlights and highlights or nil
  end
end
