-- lua/config/nvimtree.lua
-- NvimTree 插件配置

local function on_attach(bufnr)
	local api = require("nvim-tree.api")

	local function opts(desc)
		return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
	end

	-- 关键：必须调用默认映射，否则其他键（如 o, a, d 等）会失效
	api.config.mappings.default_on_attach(bufnr)

	-- 自定义映射：h 收起目录，l 打开目录或文件
	vim.keymap.set("n", "l", api.node.open.edit, opts("打开文件或目录"))
	vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("关闭目录"))
end

require("nvim-tree").setup({
	on_attach = on_attach,
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
vim.keymap.set("n", "<leader>e", ":NvimTreeFindFileToggle<CR>", { desc = "切换文件树", silent = true })

