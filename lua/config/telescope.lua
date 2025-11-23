-- lua/config/telescope.lua
-- Telescope 插件配置

-- Telescope 配置
require("telescope").setup({
	defaults = {
		sorting_strategy = "ascending",
		layout_config = {
			prompt_position = "top", -- 将搜索框放在顶部
		},
	},
})

-- 设置 telescope 快捷键
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "查找文件" })
vim.keymap.set("n", "<leader>fw", builtin.live_grep, { desc = "实时搜索" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "查找缓冲区" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "查找帮助标签" })
