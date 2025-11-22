-- lua/lsp/config.lua
-- 该文件用于配置和启动 LSP 客户端

local lsp_utils = require('lsp.utils')

local rust_lsp_config = {
    -- cmd = { '/home/user/.cargo/bin/rust-analyzer' }
    cmd = { 'rust-analyzer' }, 
    
    -- 传递给 rust-analyzer 的参数
    settings = {
        ['rust-analyzer'] = {
            inlayHints = {
                enable = true,
            },
            procMacro = {
                enable = true,
            },
        }
    },
    
    -- 绑定 utils.lua 中定义的 on_attach 函数
    on_attach = function(client, bufnr)
        lsp_utils.on_attach(client, bufnr)
        -- 这里还可以放置其他 rust_analyzer 启动后的设置
    end,
}

-- 创建一个 AutoCommand Group，方便管理和清除
local lsp_augroup = vim.api.nvim_create_augroup('CustomLspConfig', { clear = true })

-- 当打开 Rust 文件时，尝试启动 rust_analyzer
vim.api.nvim_create_autocmd('FileType', {
    group = lsp_augroup,
    pattern = 'rust', 
    callback = function(args)
        -- 确保 lsp_utils 和它的函数是可用的
        local root_dir = require('lsp.utils').find_rust_root()
        
        vim.lsp.start({
            name = 'rust_analyzer',
            cmd = rust_lsp_config.cmd,
            settings = rust_lsp_config.settings,
            root_dir = root_dir, 
            on_attach = rust_lsp_config.on_attach,
            bufnr = args.buf,
        })
    end,
})
