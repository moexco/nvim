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
	{ "<leader>t", desc = "切换终端" },
	{ "<leader>b", group = "缓冲区" },
	{ "<leader>bn", desc = "下一个缓冲区" },
	{ "<leader>bp", desc = "上一个缓冲区" },
	{ "<leader>bd", desc = "关闭当前缓冲区" },
})
