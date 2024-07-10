local function fn(
  args, -- text from i(2) in this example i.e. { { "456" } }
  parent, -- parent snippet or parent node
  user_args -- user_args from opts.user_args
)
  vim.print("args", args)
  vim.print("parent", parent)
  vim.print("user_args", user_args)
  return "[" .. args[1][1] .. user_args .. "]"
end
return {
  s({ trig = "sanmu%a*cc", trigEngine = "pattern" }, {
    -- equivalent to "${1:cond} ? ${2:then} : ${3:else}"
    i(1, "cond"),
    t " ? ",
    i(2, "then"),
    t " : ",
    i(3, "else"),
  }),
  s("wow", {
    t { "Wow! Text!", "And another line." },
  }),
  s("trigger", {
    t { "After expanding, the cursor is here ->" },
    i(1),
    t { "", "After jumping forward once, cursor is here ->" },
    i(2),
    t { "", "After jumping once more, the snippet is exited there ->" },
    i(0),
  }),
  s("trigger1", {
    i(1, "First jump"),
    t " :: ",
    sn(2, {
      i(1, "Second jump"),
      t " : ",
      i(2, "Third jump"),
    }),
  }),

  s("trig", {
    i(1),
    t "<-i(1) ",
    f(
      fn, -- callback (args, parent, user_args) -> string
      { 2 }, -- node indice(s) whose text is passed to fn, i.e. i(2)
      { user_args = { "user_args_value" } } -- opts
    ),
    t " i(2)->",
    i(2),
    t "<-i(2) i(0)->",
    i(0),
  }),
  s(
    { trig = "bb(%d)", regTrig = true },
    f(function(args, snip) return "Captured Text: " .. snip.captures[1] .. "." end, {})
  ),
}
