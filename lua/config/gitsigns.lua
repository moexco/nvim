-- lua/config/gitsigns.lua
-- Gitsigns 插件快捷键配置

vim.keymap.set("n", "]g", function()
	if vim.wo.diff then
		return "]c"
	end
	vim.wo.cursorline = true
	require("gitsigns").next_hunk()
end, { desc = "下一个 Git hunk" })
vim.keymap.set("n", "[g", function()
	if vim.wo.diff then
		return "[c"
	end
	vim.wo.cursorline = true
	require("gitsigns").prev_hunk()
end, { desc = "上一个 Git hunk" })
vim.keymap.set("n", "<leader>gs", ":Gitsigns stage_hunk<CR>", { desc = "暂存当前修改块" })
vim.keymap.set("n", "<leader>gr", ":Gitsigns reset_hunk<CR>", { desc = "回滚当前修改块" })
vim.keymap.set("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", { desc = "预览当前修改块" })
vim.keymap.set("n", "<leader>gb", ":Gitsigns blame_line<CR>", { desc = "查看当前行归属" })