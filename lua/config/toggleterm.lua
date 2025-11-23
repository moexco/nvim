
require("toggleterm").setup({
    size = 15,
    hide_numbers = true,
    shade_filetypes = {},
    shade_terminals = false,
    shading_factor = 1,
    highlights = {
        Normal = {
            guibg = "#1a1a1a", -- 设置终端背景颜色为深灰色
        },
    },

    start_in_insert = true,
    insert_mappings = true,
    terminal_mappings = true,
    persist_size = true,
    direction = "horizontal",
    close_on_exit = true,
    shell = vim.o.shell,
    term_win_exit_maps = {
        h = '<C-w>h',
        j = '<C-w>j',
        k = '<C-w>k',
        l = '<C-w>l',
    },
})