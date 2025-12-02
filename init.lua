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

-- 加载 LSP 重启命令
require("lsp.restart_lsp")

-- 加载自定义补全配置
require("utils.completion_loader").setup()

-- 启动时自动检查配置更新
require("utils.version_checker").check_startup()
