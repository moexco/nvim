-- lua/plugins.lua
-- 插件声明与 Lazy Loading 实现

vim.loader.enable()

-- =============================================================================
-- 1. 插件定义 (Plugin Specs)
-- =============================================================================

local plugins = {
	-- [Group A: 立即加载]
	-- 核心依赖、UI 组件、主题、全局按键管理
	{ "https://github.com/nvim-tree/nvim-web-devicons" },
	{ "https://github.com/nvim-lua/plenary.nvim" },
	{ "https://github.com/MunifTanjim/nui.nvim" },

	{ "https://github.com/Mofiqul/dracula.nvim",       config = "config.dracula" },
	{ "https://github.com/folke/noice.nvim",           config = "config.noice" },
	{ "https://github.com/akinsho/bufferline.nvim",    config = "config.bufferline" },
	{ "https://github.com/folke/which-key.nvim",       config = "config.whichkey" },
	{ "https://github.com/numToStr/Navigator.nvim",    config = "config.navigator" },

	-- [Group C: 打开文件时加载]
	-- 代码高亮、Git 符号
	{
		"https://github.com/nvim-treesitter/nvim-treesitter",
		deps = { "https://github.com/nvim-treesitter/nvim-treesitter-context" },
		config = "config.treesitter",
		event = { "BufReadPost", "BufNewFile" },
	},
	{
		"https://github.com/lewis6991/gitsigns.nvim",
		config = "config.gitsigns",
		event = { "BufReadPre", "BufNewFile" },
	},

	-- [Group D: 按需交互加载]
	-- 搜索、文件树、终端、补全
	{
		"https://github.com/nvim-tree/nvim-tree.lua",
		config = "config.nvimtree",
		keys = { { "n", "<leader>e" } }, -- 仅定义触发键，具体命令由 config 定义
		cmd = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeFindFile" },
	},
	{
		"https://github.com/akinsho/toggleterm.nvim",
		config = "config.toggleterm",
		keys = { { "n", "<leader>t" } },
		cmd = "ToggleTerm",
	},
	{
		"https://github.com/nvim-telescope/telescope.nvim",
		config = "config.telescope",
		cmd = "Telescope",
		-- Telescope 快捷键较多，通常在 keymaps.lua 或 config.telescope 定义
		-- 这里为了简单，我们在打开文件时也预加载它，或者等待命令触发
		event = "BufReadPre",
	},

	-- 补全与自动对
	{
		"https://github.com/hrsh7th/nvim-cmp",
		deps = {
			"https://github.com/hrsh7th/cmp-nvim-lsp",
			"https://github.com/hrsh7th/cmp-buffer",
			"https://github.com/hrsh7th/cmp-path",
			"https://github.com/L3MON4D3/LuaSnip",
			"https://github.com/saadparwaiz1/cmp_luasnip",
			"https://github.com/windwp/nvim-autopairs",
		},
		config = "completion",
		event = "InsertEnter",
	},
	{
		"https://github.com/windwp/nvim-autopairs",
		config = "config.autopairs",
		event = "InsertEnter",
	},

	-- [特定文件类型]
	{
		"https://github.com/MeanderingProgrammer/render-markdown.nvim",
		deps = { "https://github.com/3rd/image.nvim" },
		config = "config.markdown",
		ft = "markdown",
	},
}

-- =============================================================================
-- 2. 安装逻辑
-- =============================================================================
local install_list = {}
for _, p in ipairs(plugins) do
	table.insert(install_list, p[1])
	if p.deps then
		for _, dep in ipairs(p.deps) do
			table.insert(install_list, dep)
		end
	end
end
vim.pack.add(install_list)

-- =============================================================================
-- 3. Lazy 加载核心逻辑
-- =============================================================================

local pm = require("utils.plugin_manager")
local loaded_configs = {}

local function load_config(name)
	if not name or loaded_configs[name] then return end

	local start_time = vim.loop.hrtime()
	local ok, err = pcall(require, name)
	local end_time = vim.loop.hrtime()

	-- 记录耗时 (纳秒 -> 毫秒)
	pm.record_load_time(name, (end_time - start_time) / 1000000)

	if not ok then
		vim.notify("LazyLoad Error: " .. name .. "\n" .. err, vim.log.levels.ERROR)
	end
	loaded_configs[name] = true
end

-- 按键触发器 (FeedKeys 模式)
local function setup_key_trigger(key_spec, config_name)
	local mode, lhs = key_spec[1], key_spec[2]

	-- 如果已经有映射，可能是其他插件或 keymaps.lua 设置的，我们需要小心处理
	-- 这里假设 Lazy 声明的键位是“尚未加载”的功能

	vim.keymap.set(mode, lhs, function()
		-- 1. 删除当前的垫片映射 (为了让后续的 feedkeys 生效)
		vim.keymap.del(mode, lhs)

		-- 2. 加载配置 (这应该会设置真正的映射)
		load_config(config_name)

		-- 3. 重放按键
		-- 使用 feedkeys 模拟用户再次按下该键
		-- 'm' = remap (允许递归映射，这样才能触发刚加载好的插件映射)
		local keys = vim.api.nvim_replace_termcodes(lhs, true, false, true)
		vim.api.nvim_feedkeys(keys, 'm', true)
	end, { desc = "LazyLoad Trigger for " .. config_name })
end

-- 命令触发器
local function setup_cmd_trigger(cmd_name, config_name)
	vim.api.nvim_create_user_command(cmd_name, function(opts)
		vim.api.nvim_del_user_command(cmd_name)
		load_config(config_name)
		-- 重放命令
		vim.cmd(cmd_name .. (opts.args and (" " .. opts.args) or ""))
	end, { nargs = "*", bang = true })
end

-- 初始化
for _, p in ipairs(plugins) do
	if p.config then
		local lazy = p.event or p.cmd or p.ft or p.keys

		if not lazy then
			-- [A 类] 立即加载
			load_config(p.config)
		else
			-- [Events]
			if p.event then
				vim.api.nvim_create_autocmd(p.event, {
					pattern = "*",
					once = true,
					callback = function() load_config(p.config) end,
				})
			end

			-- [Filetype]
			if p.ft then
				vim.api.nvim_create_autocmd("FileType", {
					pattern = p.ft,
					once = true,
					callback = function() load_config(p.config) end,
				})
			end

			-- [Commands]
			if p.cmd then
				local cmds = type(p.cmd) == "table" and p.cmd or { p.cmd }
				for _, c in ipairs(cmds) do
					setup_cmd_trigger(c, p.config)
				end
			end

			-- [Keys]
			if p.keys then
				for _, k in ipairs(p.keys) do
					setup_key_trigger(k, p.config)
				end
			end
		end
	end
end

