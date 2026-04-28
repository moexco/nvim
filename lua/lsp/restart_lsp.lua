local function restart_lsp()
	local bufnr = vim.api.nvim_get_current_buf()

	vim.diagnostic.reset(nil, bufnr)
	vim.cmd("lsp restart")
	print("LSP Restarted & Diagnostics Cleared")
end

vim.api.nvim_create_user_command("LspRestart", restart_lsp, {})
