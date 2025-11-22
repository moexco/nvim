-- lua/config/whichkey.lua
-- Which-key 插件配置和快捷键注册

-- Which-key 配置
require("which-key").setup({})

-- 为 leader 前缀注册描述
local wk = require("which-key")
wk.add({
	{ "<leader>e", group = "文件树" },
	{ "<leader>f", group = "查找" },
	{ "<leader>g", group = "Git" },
	{ "<leader>l", group = "LSP" },
	{ "<leader>li", desc = "显示 LSP 客户端信息" },
	{ "<leader>q", group = "关闭/退出" },
})
