-- lua/lsp/config.lua
-- 该文件用于配置和启动 LSP 客户端

local lsp_utils = require("lsp.utils")

-- 通用的根目录查找函数
-- 尝试查找 git 仓库根目录，如果没有则返回当前文件所在目录
local find_project_root = function()
    local current_dir = vim.fn.expand("%:p:h")
    local git_root = vim.fn.systemlist("git -C " .. vim.fn.shellescape(current_dir) .. " rev-parse --show-toplevel 2>/dev/null")[1]
    if git_root ~= "" and vim.v.shell_error == 0 then
        return git_root
    end
    return current_dir
end

-- LSP 客户端配置表
local servers = {
    rust = { -- Changed key from rust_analyzer to rust for filetype matching
        cmd = { "rust-analyzer" },
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
        root_dir = function(fname)
            -- Use the specific rust root finder
            return require("lsp.utils").find_rust_root()
        end,
    },
    go = { -- Key for go filetype
        cmd = { "gopls" },
        settings = {
            gopls = {
                completeUnimported = true,
                usePlaceholders = true,
                analyses = {
                    unusedparams = true,
                },
            },
        },
        root_dir = function(fname)
            -- For Go, gopls typically finds its root based on go.mod or current dir
            local go_mod_root = vim.fn.systemlist("go env GOMOD 2>/dev/null")[1]
            if go_mod_root ~= "" then
                return vim.fn.fnamemodify(go_mod_root, ":h")
            end
            return find_project_root()
        end,
    },
    lua = { -- Key for lua filetype
        cmd = { "lua-language-server" },
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
        root_dir = function(fname)
            -- For Lua, try to find a project root by looking for common config files or git root
            local current_dir = vim.fn.expand("%:p:h")
            local config_files = { ".luacheckrc", ".stylua.toml", "sumneko-lua-ls.lua", ".git" }
            for _, file in ipairs(config_files) do
                local path = current_dir
                while path do
                    if vim.fn.isdirectory(path .. "/" .. file) == 1 or vim.fn.filereadable(path .. "/" .. file) == 1 then
                        return path
                    end
                    local parent_dir = vim.fn.fnamemodify(path, ":h")
                    if parent_dir == path then
                        break
                    end
                    path = parent_dir
                end
            end
            return current_dir
        end,
    },
    -- Add more servers here if needed
}

-- LSP 和诊断UI设置
-- 设置诊断显示符号
vim.fn.sign_define("LspDiagnosticsSignError", { text = "", texthl = "LspDiagnosticsSignError" })
vim.fn.sign_define("LspDiagnosticsSignWarning", { text = "", texthl = "LspDiagnosticsSignWarning" })
vim.fn.sign_define("LspDiagnosticsSignInformation", { text = "", texthl = "LspDiagnosticsSignInformation" })
vim.fn.sign_define("LspDiagnosticsSignHint", { text = "💡", texthl = "LspDiagnosticsSignHint" })

-- 设置诊断悬浮窗口的配置
vim.diagnostic.config({
	virtual_text = true,
	update_in_insert = false,
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

-- 当打开支持 LSP 的文件时，尝试启动相应的 LSP 客户端
vim.api.nvim_create_autocmd("FileType", {
    group = lsp_augroup,
    pattern = { "rust", "go", "lua" }, -- 扩展支持的文件类型
    callback = function(args)
        local filetype = vim.bo[args.buf].filetype
        local server_config = servers[filetype] -- Directly use filetype as key

        if server_config then
            local root_dir_func = server_config.root_dir or find_project_root
            local root_dir = root_dir_func(vim.api.nvim_buf_get_name(args.buf))

            vim.lsp.start({
                name = filetype,
                cmd = server_config.cmd,
                settings = server_config.settings,
                root_dir = root_dir,
                on_attach = function(client, bufnr)
                    lsp_utils.on_attach(client, bufnr)
                end,
                bufnr = args.buf,
            })
        end
    end,
})
