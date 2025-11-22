-- lua/plugins.lua
-- 该文件用于声明和配置所有插件

vim.loader.enable() -- 启用 Neovim 的 Lua 模块加载器优化

-- 使用 Neovim 0.12+ 内置的包管理器
vim.pack.add({
	-- 基础功能
	"https://github.com/nvim-tree/nvim-tree.lua",
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/numToStr/Navigator.nvim",
	"https://github.com/windwp/nvim-autopairs",
	"https://github.com/nvim-lua/plenary.nvim", -- telescope 的依赖
	"https://github.com/nvim-telescope/telescope.nvim",

	-- 主题
	"https://github.com/Mofiqul/dracula.nvim",

	-- Treesitter
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
	"https://github.com/nvim-treesitter/nvim-treesitter-context",

	-- UI 增强
	"https://github.com/folke/noice.nvim",
	"https://github.com/MunifTanjim/nui.nvim",
	"https://github.com/lewis6991/gitsigns.nvim", -- 添加 gitsigns.nvim
	"https://github.com/folke/which-key.nvim",

	-- 自动补全
	"https://github.com/hrsh7th/nvim-cmp",
	"https://github.com/hrsh7th/cmp-nvim-lsp",
	"https://github.com/hrsh7th/cmp-buffer",
	"https://github.com/hrsh7th/cmp-path",
	"https://github.com/L3MON4D3/LuaSnip",  -- 代码片段引擎
	"https://github.com/saadparwaiz1/cmp_luasnip", -- nvim-cmp 和 LuaSnip 的集成
})

-- =============================================================================
-- 插件配置
-- =============================================================================

require("config.treesitter")
require("config.dracula")
require("config.navigator")
require("config.autopairs")
require("config.noice")
require("config.nvimtree")
require("config.gitsigns")
require("completion")
require("config.telescope")
require("config.whichkey")
