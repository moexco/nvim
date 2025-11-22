-- lua/config/nvimtree.lua
-- NvimTree 插件配置

require("nvim-tree").setup({
	git = {
		enable = true,
		ignore = false, -- Set to true to ignore files in .gitignore
	},
})

-- 切换文件树
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "切换文件树" })

