local function restart_lsp()
	local bufnr = vim.api.nvim_get_current_buf()

	-- 1. 清除当前缓冲区的诊断信息 (防止旧报错残留)
	vim.diagnostic.reset(nil, bufnr)

	-- 2. 停止当前缓冲区的客户端
	local clients = vim.lsp.get_clients({ bufnr = bufnr })
	for _, client in ipairs(clients) do
		client.stop()
	end

	-- 3. 重新加载 Buffer，触发 FileType 自动命令重新启动 LSP
	vim.schedule(function()
		vim.cmd("edit")
		print("LSP Restarted & Diagnostics Cleared")
	end)
end

vim.api.nvim_create_user_command("LspRestart", restart_lsp, {})
