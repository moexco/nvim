-- lua/keymaps.lua
-- 该文件用于设置全局快捷键

-- 禁用 gc 菜单，并将 gc 指向 gcc (切换行注释)
vim.keymap.set("n", "gc", "gcc", { desc = "切换行注释" })

-- 窗口/终端复用器切换 (Ctrl + hjkl)
vim.keymap.set("n", "<C-h>", "<cmd>NavigatorLeft<CR>", { desc = "切换到左侧窗口" })
vim.keymap.set("n", "<C-j>", "<cmd>NavigatorDown<CR>", { desc = "切换到下方窗口" })
vim.keymap.set("n", "<C-k>", "<cmd>NavigatorUp<CR>", { desc = "切换到上方窗口" })
vim.keymap.set("n", "<C-l>", "<cmd>NavigatorRight<CR>", { desc = "切换到右侧窗口" })

-- 全局快捷键
vim.keymap.set("n", "<leader>q", ":qa<CR>", { desc = "关闭所有缓冲区并退出程序" })
vim.keymap.set("n", "<C-s>", ":w<CR>", { desc = "保存当前缓冲区" })
vim.keymap.set("n", "<leader>t", "<cmd>ToggleTerm<CR>", { desc = "Toggle bottom terminal" })

-- 针对终端模式的窗口/终端复用器切换 (C-hjkl)
vim.keymap.set("t", "<C-h>", "<cmd>NavigatorLeft<CR>", { desc = "终端: 切换到左侧窗口" })
vim.keymap.set("t", "<C-j>", "<cmd>NavigatorDown<CR>", { desc = "终端: 切换到下方窗口" })
vim.keymap.set("t", "<C-k>", "<cmd>NavigatorUp<CR>", { desc = "终端: 切换到上方窗口" })
vim.keymap.set("t", "<C-l>", "<cmd>NavigatorRight<CR>", { desc = "终端: 切换到右侧窗口" })

-- Bufferline 快捷键
vim.keymap.set("n", "<leader>bn", ":BufferLineCycleNext<CR>", { desc = "切换到下一个缓冲区", silent = true })
vim.keymap.set("n", "<leader>bp", ":BufferLineCyclePrev<CR>", { desc = "切换到上一个缓冲区", silent = true })
vim.keymap.set("n", "<leader>bd", function()
	local cur = vim.api.nvim_get_current_buf()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if buf ~= cur and vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted and vim.bo[buf].buftype == "" then
			vim.api.nvim_win_set_buf(0, buf)
			vim.api.nvim_buf_delete(cur, { force = true })
			return
		end
	end
	vim.api.nvim_buf_set_name(cur, "")
	vim.api.nvim_buf_set_lines(cur, 0, -1, true, { "" })
	vim.bo[cur].modified = false
end, { desc = "关闭当前缓冲区", silent = true })

-- 自定义缓冲区导航快捷键
vim.keymap.set("n", "[b", ":BufferLineCyclePrev<CR>", { desc = "切换到上一个缓冲区", silent = true })
vim.keymap.set("n", "]b", ":BufferLineCycleNext<CR>", { desc = "切换到下一个缓冲区", silent = true })
vim.keymap.set("n", "H", "[b", { desc = "切换到上一个缓冲区", remap = true, silent = true })
vim.keymap.set("n", "L", "]b", { desc = "切换到下一个缓冲区", remap = true, silent = true })

-- Telescope Git 快捷键
vim.keymap.set("n", "<leader>fg", function()
	require("telescope.builtin").git_files()
end, { desc = "查找 Git 仓库文件" })

vim.keymap.set("n", "<leader>gc", function()
	require("telescope.builtin").git_status()
end, { desc = "查找 Git 已修改的文件" })

-- 插件管理快捷键
vim.keymap.set("n", "<leader>pd", function()
	require("utils.plugin_manager").detect_broken_plugins()
end, { desc = "扫描并修复损坏的插件" })

vim.keymap.set("n", "<leader>pr", function()
	require("utils.plugin_manager").reinstall_all()
end, { desc = "重装所有插件 (清除数据)" })

vim.keymap.set("n", "<leader>ph", function()
	require("utils.plugin_manager").check_health()
end, { desc = "检查健康状况 (CheckHealth)" })

vim.keymap.set("n", "<leader>pp", function()
	require("utils.plugin_manager").show_load_times()
end, { desc = "显示插件启动耗时" })

-- 版本检查快捷键
vim.keymap.set("n", "<leader>pv", function()
	require("utils.version_checker").show_version_info()
end, { desc = "显示版本信息与更新检查" })
