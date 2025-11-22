-- lua/lsp/utils.lua

local M = {}

-- [[ 1. 最终的、纯原生 Lua 根目录查找函数 ]]
M.find_rust_root = function()
    -- 获取当前文件所在的目录
    local current_dir = vim.fn.expand('%:p:h') 
    
    while current_dir do
        -- 检查是否存在 Cargo.toml 文件 (使用 filereadable 检查文件是否存在)
        if vim.fn.filereadable(current_dir .. '/Cargo.toml') == 1 then
            return current_dir
        end
        
        -- 向上查找父目录 (使用 fnamemodify(':h') 实现)
        local parent_dir = vim.fn.fnamemodify(current_dir, ':h')
        
        -- 如果父目录和当前目录相同 (例如在文件系统根目录 '/'), 则停止
        if parent_dir == current_dir then
            break 
        end
        
        current_dir = parent_dir
    end

    -- 最终 fallback 到当前文件所在的目录
    return vim.fn.expand('%:p:h')
end


-- [[ 2. 通用的 on_attach 函数 (保持不变) ]]
M.on_attach = function(client, bufnr)
    local opts = { noremap = true, silent = true, buffer = bufnr }

    

    -- 常用的 LSP 快捷键映射... (此处代码省略，假设与上一份配置相同)

    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)

    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)

    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)

    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)

    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)

    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)

    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)

    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)

    

    -- 诊断快捷键

    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)

    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)

    

        -- Rust 独有的快捷键 

    

        vim.keymap.set('n', '<leader>rr', function()

    

            vim.cmd('RustLsp runnables')

    

        end, opts)

    

    end

    

    

    

    return M

    

    
