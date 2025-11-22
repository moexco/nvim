-- lua/config/whichkey.lua
-- Which-key 插件配置和快捷键注册

-- Which-key 配置
require("which-key").setup({})

-- 为 leader 前缀注册描述
local wk = require("which-key")
wk.register({
  e = { group = "文件树" },
  f = { group = "查找" },
  g = { group = "Git" },
  l = {
      name = "LSP",
      f = { "格式化代码" },
      i = { "显示 LSP 客户端信息" },
  },
  q = { group = "关闭/退出" }, -- 添加 leader+q 的描述
}, { prefix = "<leader>" })