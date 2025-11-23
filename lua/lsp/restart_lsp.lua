local function restart_lsp()
  -- Stop all clients for current buffer
  for _, client in pairs(vim.lsp.get_active_clients({ bufnr = 0 })) do
    vim.lsp.stop_client(client.id, true)
  end
  -- Reload buffer filetype to re-trigger lspconfig setup
  vim.cmd("edit")
end

vim.api.nvim_create_user_command("LspRestart", restart_lsp, {})
