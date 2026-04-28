-- lua/lsp/config.lua
-- 该文件用于配置和启动 LSP 客户端

local lsp_utils = require("lsp.utils")
local tools_manager = require("lsp.tools_manager")
tools_manager.setup()

local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_blink, blink = pcall(require, "blink.cmp")
if ok_blink then
	capabilities = blink.get_lsp_capabilities(capabilities)
end

-- LSP 和诊断UI设置
vim.diagnostic.config({
	virtual_text = true,
	update_in_insert = false,
	severity_sort = true,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "",
			[vim.diagnostic.severity.WARN] = "",
			[vim.diagnostic.severity.INFO] = "",
			[vim.diagnostic.severity.HINT] = "💡",
		},
	},
	float = {
		source = "always",
		focusable = false,
		border = "rounded",
	},
})

-- LSP 格式化快捷键
vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format, { desc = "LSP 格式化代码" })

-- 显示 LSP 信息 (现在使用浮动窗口)
vim.keymap.set("n", "<leader>li", function()
	require("lsp.utils").show_lsp_info()
end, { desc = "显示 LSP 客户端信息 (浮动窗口)" })

-- 创建一个 AutoCommand Group，方便管理和清除
local lsp_augroup = vim.api.nvim_create_augroup("CustomLspConfig", { clear = true })

vim.lsp.config("*", {
	capabilities = capabilities,
})

vim.lsp.config("rust_analyzer", {
	cmd = { "rust-analyzer" },
	filetypes = { "rust" },
	root_markers = { "Cargo.toml", "rust-project.json", ".git" },
	workspace_required = false,
	settings = {
		["rust-analyzer"] = {
			inlayHints = {
				enable = true,
			},
			procMacro = {
				enable = true,
			},
		},
	},
})

vim.lsp.config("gopls", {
	cmd = { "gopls" },
	filetypes = { "go", "gomod", "gowork" },
	root_markers = { "go.work", "go.mod", ".git" },
	workspace_required = false,
	settings = {
		gopls = {
			completeUnimported = true,
			usePlaceholders = true,
			analyses = {
				unusedparams = true,
				staticcheck = true,
			},
			gofumpt = true,
		},
	},
})

vim.lsp.config("lua_ls", {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = { { ".luarc.json", ".luarc.jsonc" }, ".stylua.toml", ".git" },
	workspace_required = false,
	settings = {
		Lua = {
			workspace = {
				checkThirdParty = false,
			},
			telemetry = {
				enable = false,
			},
		},
	},
})

vim.api.nvim_create_autocmd("FileType", {
	group = lsp_augroup,
	pattern = { "rust", "go" },
	callback = function(args)
		local filetype = vim.bo[args.buf].filetype
		if filetype == "go" or filetype == "rust" then
			tools_manager.check_and_install(filetype, false)
		end
	end,
})

vim.api.nvim_create_autocmd("LspAttach", {
	group = lsp_augroup,
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if not client then
			return
		end

		if client.name == "gopls" then
			lsp_utils.setup_go_organize_imports(args.buf)
		end

		lsp_utils.on_attach(client, args.buf)
	end,
})

vim.lsp.enable({ "rust_analyzer", "gopls", "lua_ls" })
