local function restart_lsp()
	local bufnr = vim.api.nvim_get_current_buf()
	local clients = vim.lsp.get_clients({ bufnr = bufnr })

	if #clients == 0 then
		vim.notify("当前缓冲区无活动的 LSP 客户端", vim.log.levels.WARN)
		return
	end

	vim.diagnostic.reset(nil, bufnr)

	local names = {}
	for _, client in ipairs(clients) do
		table.insert(names, client.name)
	end

	local ok, err = pcall(vim.cmd, "lsp restart " .. table.concat(names, " "))
	if not ok then
		vim.notify("LSP 重启失败: " .. tostring(err), vim.log.levels.ERROR)
		return
	end
	vim.notify("LSP 已重启: " .. table.concat(names, ", "), vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("LspRestart", restart_lsp, {})
