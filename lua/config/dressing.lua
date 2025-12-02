require("dressing").setup({
	input = {
		enabled = true,
		default_prompt = "Input:",
		border = "rounded",
		relative = "cursor",
	},
	select = {
		enabled = true,
		-- 优先使用 "telescope" 后端，因为它在处理复杂列表和搜索时体验更好，
		-- 且用户已安装 Telescope。如果失败则回退到 builtin。
		backend = { "telescope", "builtin" },
		trim_prompt = true,
		builtin = {
			-- 显示数字编号，方便快速选择
			show_numbers = true,
			border = "rounded",
			-- 使用 editor 相对定位，居中显示，比 cursor 更整洁
			relative = "editor",
			win_options = {
				cursorline = true,
				cursorlineopt = "both",
				-- 禁用透明度，防止在某些终端下背景渲染混乱
				winblend = 0,
			},
			-- 限制最大宽高，防止占满屏幕
			max_width = { 140, 0.8 },
			min_width = { 40, 0.2 },
			max_height = 0.9,
			min_height = { 10, 0.2 },
			
			mappings = {
				["<Esc>"] = "Close",
				["<C-c>"] = "Close",
				["<CR>"] = "Confirm",
			},
		},
	},
})