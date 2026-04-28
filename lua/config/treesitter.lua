-- lua/config/treesitter.lua
-- Treesitter 解析器安装与官方高亮启动

require("nvim-treesitter").setup({})

require("nvim-treesitter").install({ "rust", "go" })

local enabled_filetypes = {
	go = true,
	lua = true,
	markdown = true,
	rust = true,
}

local function start_treesitter(bufnr)
	local filetype = vim.bo[bufnr].filetype
	if not enabled_filetypes[filetype] then
		return
	end

	local lang = vim.treesitter.language.get_lang(filetype)
	if not lang then
		return
	end

	local ok = vim.treesitter.language.add(lang)
	if ok then
		pcall(vim.treesitter.start, bufnr, lang)
	end
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = vim.tbl_keys(enabled_filetypes),
	callback = function(args)
		start_treesitter(args.buf)
	end,
})

start_treesitter(vim.api.nvim_get_current_buf())
