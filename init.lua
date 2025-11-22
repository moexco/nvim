-- init.lua
-- Neovim 配置主入口

-- 加载基本选项
require("options")

-- 加载插件并进行配置
require("plugins")

-- 加载全局快捷键
require("keymaps")

-- 加载 LSP (语言服务器协议) 相关配置
require("lsp.config")
