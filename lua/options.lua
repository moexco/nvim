-- lua/options.lua
-- 该文件包含 Neovim 的全局设置和选项

-- 基本编辑体验
vim.opt.relativenumber = true -- 启用相对行号 (Relative Line Numbers)，方便移动
vim.opt.number = true -- 启用绝对行号 (Absolute Line Numbers)
vim.opt.tabstop = 4 -- 将 Tab 字符显示的宽度设置为 4 个空格
vim.opt.termguicolors = true -- 启用 24-位 RGB 颜色
vim.opt.undofile = true -- 启用永久撤销
vim.opt.swapfile = false -- 禁用交换文件
vim.opt.signcolumn = "yes"
vim.opt.clipboard = "unnamedplus" -- Enable system clipboard (OSC 52)

-- 全局变量
vim.g.mapleader = " " -- 将 Leader 键设置为 <Space> (空格键)
