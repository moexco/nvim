-- lua/lsp/utils.lua

local M = {}

-- [[ 1. 最终的、纯原生 Lua 根目录查找函数 ]]
M.find_rust_root = function()
	-- 获取当前文件所在的目录
	local current_dir = vim.fn.expand("%:p:h")

	while current_dir do
		-- 检查是否存在 Cargo.toml 文件 (使用 filereadable 检查文件是否存在)
		if vim.fn.filereadable(current_dir .. "/Cargo.toml") == 1 then
			return current_dir
		end

		-- 向上查找父目录 (使用 fnamemodify(':h') 实现)
		local parent_dir = vim.fn.fnamemodify(current_dir, ":h")

		-- 如果父目录和当前目录相同 (例如在文件系统根目录 '/'), 则停止
		if parent_dir == current_dir then
			break
		end

		current_dir = parent_dir
	end

	-- 最终 fallback 到当前文件所在的目录
	return vim.fn.expand("%:p:h")
end

-- [[ 2. 通用的 on_attach 函数 (保持不变) ]]
M.on_attach = function(client, bufnr)
	local opts = { noremap = true, silent = true, buffer = bufnr }

	-- 常用的 LSP 快捷键映射...
	-- local telescope_builtin = require("telescope.builtin") -- 暂时注释掉，因为 Telescope LSP 扩展未加载
	vim.keymap.set("n", "K", vim.lsp.buf.hover, { noremap = true, silent = true, buffer = bufnr, desc = "显示悬浮文档" })
	vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help,
		{ noremap = true, silent = true, buffer = bufnr, desc = "显示函数签名" })
	vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename,
		{ noremap = true, silent = true, buffer = bufnr, desc = "LSP 重命名" })
	vim.keymap.set("n", "<leader>lc", vim.lsp.buf.code_action,
		{ noremap = true, silent = true, buffer = bufnr, desc = "LSP 代码动作" })

	-- LSP Go To 系列快捷键 (G 开头)
	vim.keymap.set("n", "gd", vim.lsp.buf.definition,
		{ noremap = true, silent = true, buffer = bufnr, desc = "跳转到定义" })
	vim.keymap.set("n", "gD", vim.lsp.buf.declaration,
		{ noremap = true, silent = true, buffer = bufnr, desc = "跳转到声明" })
	vim.keymap.set("n", "gi", vim.lsp.buf.implementation,
		{ noremap = true, silent = true, buffer = bufnr, desc = "跳转到实现" })
	vim.keymap.set("n", "gt", vim.lsp.buf.type_definition,
		{ noremap = true, silent = true, buffer = bufnr, desc = "跳转到类型定义" })
	vim.keymap.set("n", "gr", vim.lsp.buf.references,
		{ noremap = true, silent = true, buffer = bufnr, desc = "查找引用" })


	-- 诊断快捷键
	vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
	vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

	-- 启用 nvim-cmp 的缓冲区本地设置
	-- 这会为每个 LSP 附加的缓冲区启用自动补全
	require("cmp").setup.buffer({
		sources = {
			{ name = "nvim_lsp" },
			{ name = "luasnip" },
			{ name = "buffer" },
			{ name = "path" },
		},
	})

	-- Rust 独有的快捷键
	vim.keymap.set("n", "<leader>lR", function()
		vim.cmd("RustLsp runnables")
	end, { noremap = true, silent = true, buffer = bufnr, desc = "RustLSP 可运行项" })
end

--- 在浮动窗口中显示 LSP 客户端信息
function M.show_lsp_info()
	local bufnr = vim.api.nvim_get_current_buf()
	local clients = vim.lsp.get_clients({ bufnr = bufnr })

	local info_lines = {}
	if next(clients) == nil then
		table.insert(info_lines, "No active LSP clients for this buffer.")
	else
		table.insert(info_lines, "Active LSP Clients for Buffer " .. bufnr .. ":")
		table.insert(info_lines, "-------------------------------------")
		for _, client in ipairs(clients) do
			table.insert(info_lines, string.format("ID: %d", client.id))
			table.insert(info_lines, string.format("Name: %s", client.name))
			table.insert(info_lines,
				string.format("Root: %s", client.config and client.config.root_dir or "N/A"))
			table.insert(
				info_lines,
				string.format("Status: %s", client.server_capabilities and "Ready" or "Initializing")
			)
			table.insert(
				info_lines,
				string.format("Autostart: %s",
					client.config and client.config.autostart and "Yes" or "No")
			)
			table.insert(info_lines, "") -- Add a blank line for readability
		end
	end

	local max_width = 0
	for _, line in ipairs(info_lines) do
		local len = vim.fn.strwidth(line)
		if len > max_width then
			max_width = len
		end
	end

	local height = #info_lines + 2                    -- +2 for padding
	local width = math.min(max_width + 4, vim.o.columns - 4) -- +4 for padding, limit width

	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, info_lines)

	local win_id = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		row = row,
		col = col,
		width = width,
		height = height,
		border = "rounded",
		style = "minimal",
		focusable = false,
		noautocmd = true,
	})

	-- Highlight the border
	vim.api.nvim_win_set_option(win_id, "winhl", "Normal:NormalFloat,FloatBorder:FloatBorder")

	-- Set keymaps for closing the floating window immediately
	vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", ":q<CR>", { silent = true })
	vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", ":q<CR>", { silent = true })
	vim.api.nvim_buf_set_keymap(buf, "n", "q", ":q<CR>", { silent = true })
	vim.api.nvim_buf_set_keymap(buf, "n", "<LeftMouse>", ":q<CR>", { silent = true }) -- Close on click
end

return M

