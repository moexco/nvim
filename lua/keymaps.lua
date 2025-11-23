-- lua/keymaps.lua
-- 该文件用于设置全局快捷键


-- 禁用 gc 菜单，并将 gc 指向 gcc (切换行注释)
vim.keymap.set("n", "gc", "gcc", { desc = "切换行注释" })

-- 窗口切换 (Ctrl + hjkl)
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "切换到左侧窗口" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "切换到下方窗口" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "切换到上方窗口" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "切换到右侧窗口" })

-- 全局快捷键
vim.keymap.set("n", "<leader>q", ":qa<CR>", { desc = "关闭所有缓冲区并退出程序" })
vim.keymap.set("n", "<C-s>", ":w<CR>", { desc = "保存当前缓冲区" })
vim.keymap.set("n", "<leader>t", "<cmd>ToggleTerm<CR>", { desc = "Toggle bottom terminal" })

-- 窗口切换 (Ctrl + hjkl) - 确保在所有普通模式下生效，包括从终端退出后
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "切换到左侧窗口" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "切换到下方窗口" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "切换到上方窗口" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "切换到右侧窗口" })

-- 针对终端模式的窗口切换 (C-hjkl)
-- 't' 模式：在终端插入模式下，先退出终端，再切换窗口
vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "终端: 切换到左侧窗口" })
vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "终端: 切换到下方窗口" })
vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "终端: 切换到上方窗口" })
vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "终端: 切换到右侧窗口" })

-- 'n' 模式：在终端普通模式下，直接切换窗口 (与全局n模式重复，但确保优先级)
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "终端/普通: 切换到左侧窗口" }) -- 覆盖现有n模式，确保优先级
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "终端/普通: 切换到下方窗口" }) -- 覆盖现有n模式，确保优先级
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "终端/普通: 切换到上方窗口" }) -- 覆盖现有n模式，确保优先级
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "终端/普通: 切换到右侧窗口" }) -- 覆盖现有n模式，确保优先级

-- Bufferline 快捷键
vim.keymap.set("n", "<leader>bn", ":BufferLineCycleNext<CR>", { desc = "切换到下一个缓冲区" })
vim.keymap.set("n", "<leader>bp", ":BufferLineCyclePrev<CR>", { desc = "切换到上一个缓冲区" })
vim.keymap.set("n", "<leader>bd", ":bdelete!<CR>", { desc = "关闭当前缓冲区" })

-- 自定义缓冲区导航快捷键
vim.keymap.set("n", "[b", ":BufferLineCyclePrev<CR>", { desc = "切换到上一个缓冲区" })
vim.keymap.set("n", "]b", ":BufferLineCycleNext<CR>", { desc = "切换到下一个缓冲区" })
vim.keymap.set("n", "H", ":BufferLineCyclePrev<CR>", { desc = "切换到上一个缓冲区" })
vim.keymap.set("n", "L", ":BufferLineCycleNext<CR>", { desc = "切换到下一个缓冲区" })

-- Telescope Git 快捷键
vim.keymap.set("n", "<leader>fg", function()
	require("telescope.builtin").git_files()
end, { desc = "查找 Git 已修改的文件" })

