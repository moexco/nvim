vim.opt.relativenumber = true -- 启用相对行号 (Relative Line Numbers)，方便移动
vim.opt.number = true         -- 启用绝对行号 (Absolute Line Numbers)
vim.opt.tabstop = 4           -- 将 Tab 字符显示的宽度设置为 4 个空格
vim.g.mapleader = " "         -- 将 Leader 键设置为 <Space> (空格键)


vim.pack.add({
  "https://github.com/nvim-tree/nvim-tree.lua",
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/numToStr/Navigator.nvim",
  "https://github.com/Mofiqul/dracula.nvim",
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  "https://github.com/nvim-treesitter/nvim-treesitter-context",
  "https://github.com/windwp/nvim-autopairs",
})

require("dracula").setup({}) -- 初始化并设置 Dracula 颜色方案 (使用默认配置)
require("nvim-treesitter.config").setup({
  ensure_installed = { "go", "lua", "html", "gotmpl", "gomod", 'gdscript', 'godot_resource', 'gdshader' },
  highlight = {
    enable = true,
  },
})
require("Navigator").setup()

vim.cmd [[colorscheme dracula]] -- 应用 Dracula 颜色方案



-- file tree
-- optionally enable 24-bit colour
vim.opt.termguicolors = true

require("nvim-tree").setup({
})


-- <Leader>e: 切换文件树 (使用 Leader 键 + e)
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = 'Toggle NvimTree' })

vim.keymap.set('n', '<leader>li', function()
		-- 纯原生 0.11 Lua 逻辑：获取客户端列表并在命令行显示
    local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })
    if next(clients) == nil then
        return
    end
    
    for _, client in ipairs(clients) do
        local bufnrs = client.request_buffers or client.config.request_buffers or {}
        local status = 'Buffer: ' .. vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
        local root = client.config and client.config.root_dir or 'N/A'
        
        print(string.format("ID: %d | 名称: %s | 根目录: %s", client.id, client.name, root))
    end

end, opts)


-- 引用通用工具模块
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
        vim.lsp.start({
            name = 'rust_analyzer',
            cmd = rust_lsp_config.cmd,
            settings = rust_lsp_config.settings,
            
            root_dir = lsp_utils.find_rust_root(), 
            
            on_attach = rust_lsp_config.on_attach,
            bufnr = args.buf,
        })
    end,
})

-- 设置诊断显示符号
vim.fn.sign_define('LspDiagnosticsSignError', { text = '', texthl = 'LspDiagnosticsSignError' })
vim.fn.sign_define('LspDiagnosticsSignWarning', { text = '', texthl = 'LspDiagnosticsSignWarning' })
vim.fn.sign_define('LspDiagnosticsSignInformation', { text = '', texthl = 'LspDiagnosticsSignInformation' })
vim.fn.sign_define('LspDiagnosticsSignHint', { text = '💡', texthl = 'LspDiagnosticsSignHint' })

-- 设置诊断悬浮窗口的延迟
vim.diagnostic.config({
    virtual_text = true,
    update_in_insert = false,
    float = {
        source = 'always',
        focusable = false,
        border = 'rounded',
    },
})

