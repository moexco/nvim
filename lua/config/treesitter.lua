-- lua/config/treesitter.lua
-- Treesitter 插件配置

require("nvim-treesitter.config").setup({
	ensure_installed = { "go", "lua", "html", "rust" },
	auto_install = true,
	highlight = {
		enable = true,
	},
	indent = { enable = true },
	incremental_selection = { enable = true }, -- 增量选择
	context_commentstring = { enable = true }, -- 注释字符串
})