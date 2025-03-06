---@class user.keymap
local M = {}

---better delete buffer
function M.bd(opts)
  Snacks.bufdelete(opts)
end

---delete all buffers except the visual windows
function M.bda_butvis()
  local tab_buflist = vim.fn.tabpagebuflist()
  M.bd(function(buf)
    return not vim.list_contains(tab_buflist, buf)
  end)
end

---delete all buffers except the current window
function M.bda_butcur()
  local bufnr = vim.api.nvim_win_get_buf(0)
  M.bd(function(buf)
    return buf ~= bufnr
  end)
end

---delete all buffers
function M.bda()
  M.bd(function(buf)
    return true
  end)
end

---Switch tab
function M.tswitch()
  if vim.fn.tabpagenr("#") == 0 then
    vim.cmd("tabnew %")
  else
    vim.cmd("tabnext #")
  end
end

---@type table<string, fun():snacks.toggle.Class>
M.toggle = {}

---@type table<string, {desc: string}>
M.motions = {
  ["$"] = { desc = "End of line" },
  ["%"] = { desc = "Matching (){}[]" },
  ["0"] = { desc = "Start of line" },
  ["F"] = { desc = "Move to prev char" },
  ["G"] = { desc = "Last line" },
  ["T"] = { desc = "Move before prev char" },
  ["^"] = { desc = "Start of line (non ws)" },
  ["b"] = { desc = "Prev word" },
  ["e"] = { desc = "Next end of word" },
  ["f"] = { desc = "Move to next char" },
  ["ge"] = { desc = "Prev end of word" },
  ["gg"] = { desc = "First line" },
  ["h"] = { desc = "Left" },
  ["j"] = { desc = "Down" },
  ["k"] = { desc = "Up" },
  ["l"] = { desc = "Right" },
  ["t"] = { desc = "Move before next char" },
  ["w"] = { desc = "Next word" },
  ["{"] = { desc = "Prev empty line" },
  ["}"] = { desc = "Next empty line" },
  [";"] = { desc = "Next ftFT" },
  [","] = { desc = "Prev ftFT" },
  ["/"] = { desc = "Search forward" },
  ["?"] = { desc = "Search backward" },
  ["B"] = { desc = "Prev WORD" },
  ["E"] = { desc = "Next end of WORD" },
  ["W"] = { desc = "Next WORD" },
}

---@type table<string, {desc: string}>
M.text_objects = {
  ['"'] = { desc = '" string' },
  ["'"] = { desc = "' string" },
  ["("] = { desc = "[(])" },
  [")"] = { desc = "[(])" },
  ["<"] = { desc = "<>" },
  [">"] = { desc = "<>" },
  ["B"] = { desc = "[{]}" },
  ["W"] = { desc = "WORD" },
  ["["] = { desc = "[]" },
  ["]"] = { desc = "[]" },
  ["`"] = { desc = "` string" },
  ["b"] = { desc = "[(])" },
  ["p"] = { desc = "paragraph" },
  ["s"] = { desc = "sentence" },
  ["t"] = { desc = "tag block" },
  ["w"] = { desc = "word" },
  ["{"] = { desc = "[{]}" },
  ["}"] = { desc = "[{]}" },
}

---@param objects table<string, string>
function M.add_text_objects(objects)
  M.text_objects = vim.tbl_extend("force", M.text_objects, objects)
end

---@param ai? string[]
function M.get_text_objects(ai)
  if ai == nil then
    return vim.tbl_keys(M.text_objects)
  end

  local ret = {}
  for _, prefix in ipairs(ai) do
    for object, _ in pairs(M.text_objects) do
      table.insert(ret, prefix .. object)
    end
  end
  return ret
end

---@param job {mode?: string[], operators?: table<string, {group: string}>, objects?: table<string, {desc: string}>, motions?: table<string, {desc: string}>}
---@param opts? wk.Parse
function M.add_which_key(job, opts)
  local ret = { mode = job.mode }
  if job.motions then
    for operator, val1 in pairs(job.operators) do
      ret[#ret + 1] = { operator, group = val1.group }

      for motion, val2 in pairs(job.motions) do
        ret[#ret + 1] = { operator .. motion, desc = val2.desc }
      end
    end
  end

  if job.objects then
    for ai, val in pairs({ i = { group = "inside" }, a = { group = "around" } }) do
      for operator, val1 in pairs(job.operators) do
        ret[#ret + 1] = { ai .. operator, group = val1.group or val.group }
        for object, val2 in pairs(job.objects) do
          ret[#ret + 1] = { ai .. operator .. object, desc = val2.desc }
        end
      end
    end
  end
  require("which-key").add(ret, opts or { notify = false })
end

return M
