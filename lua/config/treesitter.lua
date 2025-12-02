-- lua/config/treesitter.lua
-- Treesitter 插件配置

require("nvim-treesitter").setup({})


require("nvim-treesitter").install({ 'rust', 'go', 'lua', 'markdown' })


vim.api.nvim_create_autocmd('FileType', {
	pattern = { 'rust', 'go', 'lua', 'markdown' },
	callback = function() vim.treesitter.start() end,
})
