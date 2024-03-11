local M = {}

-- {} {} {} opts < array(item) opts
M.Data = {}

-- string | table
M.add_items = function(commanderOpts)
  commanderOpts = type(commanderOpts) == "table" and commanderOpts or { cat = commanderOpts }

  return function(commanderItems)
    if not commanderItems then
      return
    end
    commanderItems = #commanderItems == 0 and { commanderItems } or commanderItems
    commanderItems.opts = commanderOpts
    table.insert(M.Data, commanderItems)
  end
end

return M
