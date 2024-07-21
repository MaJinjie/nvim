`nvim_create_user_command({name}, {command}, {opts})`

1. name 命令的名称
2. 一个字符串或函数(`function(args)`)
3. 启用该用户命令的一些功能

   1. `bang: boolean` 命令后是否允许加`!`
   2. `nargs: string` 命名参数个数
   3. `complete: function(arg, cmd, pos)` 命令补全触发
   4. `range: boolean` 是否启用代码可选区域
   5. `desc: string` 命令的描述
