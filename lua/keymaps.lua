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

-- Bufferline 快捷键
vim.keymap.set("n", "<leader>bn", ":BufferLineCycleNext<CR>", { desc = "切换到下一个缓冲区" })
vim.keymap.set("n", "<leader>bp", ":BufferLineCyclePrev<CR>", { desc = "切换到上一个缓冲区" })
vim.keymap.set("n", "<leader>bd", ":bdelete!<CR>", { desc = "关闭当前缓冲区" })
