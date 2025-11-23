-- lua/config/nvimtree.lua
-- NvimTree 插件配置

require("nvim-tree").setup({
	git = {
		enable = true,
		ignore = false, -- Set to true to ignore files in .gitignore
	},
	renderer = {
		highlight_git = true, -- 启用 Git 状态高亮
		icons = {
			show = {
				git = false, -- 禁用 Git 状态图标
			},
		},
	},
})

-- 定义 Git 状态的高亮组
-- 您可以根据自己的喜好调整颜色
vim.cmd.highlight("NvimTreeGitStaged guifg=#aff5b4")   -- 已暂存 (绿色)
vim.cmd.highlight("NvimTreeGitDirty guifg=#e3b341")    -- 已修改 (黄色)
vim.cmd.highlight("NvimTreeGitNew guifg=#56d364")      -- 新增 (绿色)
vim.cmd.highlight("NvimTreeGitRenamed guifg=#f0883e")   -- 已重命名 (橙色)
vim.cmd.highlight("NvimTreeGitDeleted guifg=#f85149")  -- 已删除 (红色)
vim.cmd.highlight("NvimTreeGitIgnored guifg=#909090")  -- 已忽略 (灰色)

-- 切换文件树
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "切换文件树" })

