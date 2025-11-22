-- lua/keymaps.lua
-- 该文件用于设置全局快捷键

local opts = { noremap = true, silent = true }

-- 切换文件树
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = 'Toggle NvimTree' })

-- 显示 LSP 信息 (现在使用浮动窗口)

vim.keymap.set('n', '<leader>li', function()

    require('lsp.utils').show_lsp_info()

end, { desc = '显示 LSP 客户端信息 (浮动窗口)' })

-- 窗口切换 (Ctrl + hjkl)
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = '切换到左侧窗口' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = '切换到下方窗口' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = '切换到上方窗口' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = '切换到右侧窗口' })

-- 全局快捷键
vim.keymap.set('n', '<C-q>', ':qa<CR>', { desc = '关闭所有缓冲区并退出' })
vim.keymap.set('n', '<C-s>', ':w<CR>', { desc = '保存当前缓冲区' })

-- Gitsigns 快捷键
vim.keymap.set('n', ']g', function()
  if vim.wo.diff then return ']c' end
  vim.wo.cursorline = true
  require('gitsigns').next_hunk()
end, { desc = '下一个 Git hunk' })
vim.keymap.set('n', '[g', function()
  if vim.wo.diff then return '[c' end
  vim.wo.cursorline = true
  require('gitsigns').prev_hunk()
end, { desc = '上一个 Git hunk' })
vim.keymap.set('n', '<leader>gs', ':Gitsigns stage_hunk<CR>', { desc = 'Stage current hunk' })
vim.keymap.set('n', '<leader>gr', ':Gitsigns reset_hunk<CR>', { desc = 'Reset current hunk' })
vim.keymap.set('n', '<leader>gp', ':Gitsigns preview_hunk<CR>', { desc = 'Preview current hunk' })
vim.keymap.set('n', '<leader>gb', ':Gitsigns blame_line<CR>', { desc = 'Blame current line' })





