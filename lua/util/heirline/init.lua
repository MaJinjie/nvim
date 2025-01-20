local M = {}

local palette = require("gruvbox").palette
local colors = {
  bg = vim.api.nvim_get_hl(0, { name = "Noraml" }).bg,

  black = palette.dark0,
  white = palette.light0,
  gray = palette.gray,

  bright_red = palette.bright_red,
  bright_green = palette.bright_green,
  bright_blue = palette.bright_blue,
  bright_yellow = palette.bright_yellow,
  bright_aqua = palette.bright_aqua,
  bright_orange = palette.bright_orange,
  bright_purple = palette.bright_purple,

  dark0 = palette.dark0,
  dark1 = palette.dark1,
  dark2 = palette.dark2,
  dark3 = palette.dark3,
  dark4 = palette.dark4,
  dark0_hard = palette.dark0_hard,
  dark0_soft = palette.dark0_soft,

  dark = palette.dark0,
  dark_hard = palette.dark0_hard,
  dark_soft = palette.dark0_soft,

  light0 = palette.light0,
  light1 = palette.light1,
  light2 = palette.light2,
  light3 = palette.light3,
  light4 = palette.light4,
  light0_hard = palette.light0_hard,
  light0_soft = palette.light0_soft,

  light = palette.light4,
  light_hard = palette.light0_hard,
  light_soft = palette.light0_soft,
}

function M.setup()
  local statusline = require("util.heirline.statusline")
  local tabline = require("util.heirline.tabline")
  local statuscolumn = require("util.heirline.statuscolumn")

  statusline.init()
  statuscolumn.init()
  tabline.init()

  require("heirline").setup({
    statusline = statusline.config,
    statuscolumn = statuscolumn.config,
    tabline = tabline.config,
    opts = {
      colors = colors,
    },
  })

  statusline.setup()
  statuscolumn.setup()
  tabline.setup()
end

return M

--[[
-- StatusLine:
------------------------------------------------------------
--  @field id integer[] 表示组件的层级路径，唯一标识一个组件
--  @field winnr integer 评估到最后一个窗口的窗口号
--  @field restrict table<string,boolean> 下面是默认的私有字段，子类不可访问
--    default: init, provider, hl, condition, restrict, pick_child, after, on_click, update, fallthrough
--    
--  @field flexible integer|boolean 定义柔性组件以及它的优先级
--    - flexible不会自动传递给子组件，子组件需要为true来继承flexible
--    - 在扩展时，优先级高先扩展。在收缩时，优先级低先收缩
--    - 优先级的分配（mode 扩展1 收缩-1）
--      1 父子组件，子组件flexible = 父组件flexible + mode
--      2 同父子组件 相同
--      3 无父组件 flexible保持不变
--    
--  @field merged_hl 私有，高亮合并
--  @field _win_cache 缓存组件评估结果,在指定update时使用，由update触发重置
--  @field _au_id 注册自动命令的id
--  @field _updatable_components 要更新的组件表
-------------------------------------------------------------
--  @method new(child, index) 
--   - 可以手动调用动态建立组件,递归执行
--   - 如果手动执行，需要传入index来生成一个正确的组件层级路径
--  @method get(id) 获取指定组件
--  @method find(func) 递归查找组件
--  @method is_child(other) self是否是other的孩子
--  @method broadcast(func) 递归对所有组件执行函数，不返回结果
--  @method nonlocal(attr) 获取父类的字段，但依然受restrict限制
--  @method local_(attr) 使用rawget访问本地字段
--
--  @method _eval() 递归评估所有组件并将值记录到_tree中
--    1 condition 
--    2 update 更新_win_cache以及执行一些其他回调操作
--    3 init
--    4 flexible 修改pick_child为柔性评估的组件
--    5 hl 并与父组件的高亮合并
--    6 on_click 注册点击事件，并插入tree
--    7 provider 计算并插入tree
--    8 pick_child|nil 按照顺序递归_eval
--    9 after
--    
--  @method traverse() 合并组件树的输出，返回最后的值（组件评估之后进行）
--  @method eval() 以上两个方法的合并
-------------------------------------------------------------
--  ---@alias HeirlineOnClickCallback string|fun(self: StatusLine, minwid: integer, nclicks: integer, button: "l"|"m"|"r", mods: string)
--  ---@class HeirlineOnClick
--  ---@field callback string|HeirlineOnClickCallback
--  ---@field name string|fun(self?: StatusLine):string
--  ---@field update? boolean
--- ---@field minwid? number|fun(self: StatusLine):integer
---   如果没设置或为""，取决于组件本身
--]]
