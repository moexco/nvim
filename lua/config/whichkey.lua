-- lua/config/whichkey.lua
-- Which-key 插件配置和快捷键注册

-- Which-key 配置
require("which-key").setup({})

-- 为 leader 前缀注册描述
local wk = require("which-key")
wk.add({
	{ "<leader>a", group = "AI" },
	{ "<leader>aa", desc = "AI 动作面板" },
	{ "<leader>ac", desc = "切换 Codex Chat" },
	{ "<leader>ad", desc = "发送诊断到 Codex CLI" },
	{ "<leader>ai", desc = "发送当前上下文到 Codex CLI" },
	{ "<leader>al", desc = "选择 Codex 登录方式" },
	{ "<leader>ap", desc = "向 Codex CLI 提问" },
	{ "<leader>ar", desc = "恢复 Codex 会话" },
	{ "<leader>as", desc = "显示 AI 状态" },
	{ "<leader>at", desc = "切换 Codex CLI" },
	{ "<leader>e", group = "文件树" },
	{ "<leader>f", group = "查找" },
	{ "<leader>g", group = "Git" },
	{ "<leader>l", group = "LSP" },
	{ "<leader>li", desc = "显示 LSP 客户端信息" },
	{ "<leader>q", group = "关闭/退出" },
	{ "<leader>t", desc = "切换终端" },
	{ "<leader>v", group = "视图/模式" },
	{ "<leader>vr", desc = "切换 Review Mode" },
	{ "<leader>b", group = "缓冲区" },
	{ "<leader>bn", desc = "下一个缓冲区" },
	{ "<leader>bp", desc = "上一个缓冲区" },
	{ "<leader>bd", desc = "关闭当前缓冲区" },
	{ "<leader>p", group = "插件管理" },
})
