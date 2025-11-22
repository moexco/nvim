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
})

-- =============================================================================
-- 插件配置
-- =============================================================================

-- 主题配置
require("dracula").setup({})
vim.cmd([[colorscheme dracula]]) -- 应用颜色方案

-- Treesitter 配置
require("nvim-treesitter.config").setup({
	ensure_installed = { "go", "lua", "html", "gotmpl", "gomod", "gdscript", "godot_resource", "gdshader" },
	highlight = {
		enable = true,
	},
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