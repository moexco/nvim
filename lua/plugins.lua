-- lua/plugins.lua
-- 该文件用于声明和配置所有插件

-- 使用 Neovim 0.12+ 内置的包管理器
vim.pack.add({
	-- 基础功能
	"https://github.com/nvim-tree/nvim-tree.lua",
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/numToStr/Navigator.nvim",
	"https://github.com/windwp/nvim-autopairs",

	-- 主题
	"https://github.com/Mofiqul/dracula.nvim",

	-- Treesitter
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
	"https://github.com/nvim-treesitter/nvim-treesitter-context",

	-- UI 增强
	"https://github.com/folke/noice.nvim",
	"https://github.com/MunifTanjim/nui.nvim",
	"https://github.com/lewis6991/gitsigns.nvim", -- 添加 gitsigns.nvim

	-- 自动补全
	"https://github.com/hrsh7th/nvim-cmp",
	"https://github.com/hrsh7th/cmp-nvim-lsp",
	"https://github.com/hrsh7th/cmp-buffer",
	"https://github.com/hrsh7th/cmp-path",
	"https://github.com/L3MON4D3/LuaSnip", -- 代码片段引擎
	"https://github.com/saadparwaiz1/cmp_luasnip", -- nvim-cmp 和 LuaSnip 的集成
})

-- =============================================================================
-- 插件配置
-- =============================================================================

-- 主题配置
require("dracula").setup({})
vim.cmd([[colorscheme dracula]]) -- 应用颜色方案

-- Treesitter 配置
require("nvim-treesitter.config").setup({
	ensure_installed = { "go", "lua", "html", "gomod", "rust" },
	highlight = {
		enable = true,
	},
	indent = { enable = true },
	incremental_selection = { enable = true }, -- 增量选择
	context_commentstring = { enable = true }, -- 注释字符串
})

-- NvimTree (文件树) 配置
require("nvim-tree").setup({
	git = {
		enable = true,
		ignore = false, -- Set to true to ignore files in .gitignore
	},
})

-- 其他插件配置
require("Navigator").setup()
require("nvim-autopairs").setup() -- 启用自动配对

-- Noice.nvim (UI美化) 配置
require("noice").setup({
	lsp = {
		progress = {
			enabled = true,
			view = "mini",
		},
		override = {
			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
			["vim.lsp.util.stylize_markdown"] = true,
			["cmp.entry.get_documentation"] = true,
		},
	},
	presets = {
		bottom_search = true,
		command_palette = true,
		long_message_to_split = true,
		inc_rename = false,
		lsp_doc_border = false,
	},
})

-- 自动补全配置
require("completion")
