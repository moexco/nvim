local M = {}

-- 辅助函数：执行 shell 命令并返回结果（去除首尾空白）
local function exec_git(cmd, cwd)
	-- 构建命令时，显式指定工作目录
	-- 注意：git -C <path> 可以指定 git 运行的目录
	local full_cmd = string.format("git -C %s %s", vim.fn.shellescape(cwd), cmd)
	local handle = io.popen(full_cmd)
	if not handle then return nil end
	local result = handle:read("*a")
	handle:close()
	if result then
		return result:gsub("^%s*(.-)%s*$", "%1")
	end
	return ""
end

-- 获取 Neovim 配置目录
local function get_config_dir()
	return vim.fn.stdpath("config")
end

-- 异步执行 git fetch，避免阻塞
local function git_fetch(callback)
	local config_dir = get_config_dir()
	-- 异步 jobstart 可以直接设置 cwd 参数
	vim.fn.jobstart({ "git", "fetch", "origin", "master" }, {
		cwd = config_dir,
		on_exit = function(_, code) 
			if code == 0 then
				if callback then callback() end
			end
		end,
	})
end

function M.get_git_info()
	local config_dir = get_config_dir()
	
	-- 检查是否为 git 仓库
	local is_git = exec_git("rev-parse --is-inside-work-tree 2>/dev/null", config_dir)
	if is_git ~= "true" then
		return { error = "Config dir is not a git repo: " .. config_dir }
	end

	-- 获取远程地址
	local remote_url = exec_git("remote get-url origin 2>/dev/null", config_dir)
	if remote_url == "" then
		return { error = "No remote 'origin' found in config dir" }
	end

	-- 获取本地状态
	local local_hash = exec_git("rev-parse --short HEAD", config_dir)
	local local_time = exec_git("log -1 --format=%cd --date=relative HEAD", config_dir)
	local is_dirty = exec_git("status --porcelain", config_dir) ~= ""

	-- 获取远程状态 (假设已经 fetch 过)
	local remote_hash = exec_git("rev-parse --short origin/master 2>/dev/null", config_dir)
	local remote_time = ""
	
	if remote_hash ~= "" then
		remote_time = exec_git("log -1 --format=%cd --date=relative origin/master 2>/dev/null", config_dir)
	end

	return {
		config_path = config_dir,
		remote_url = remote_url,
		local_hash = local_hash,
		local_time = local_time,
		is_dirty = is_dirty,
		remote_hash = remote_hash,
		remote_time = remote_time,
	}
end

-- 启动时静默检查
function M.check_startup()
	local config_dir = get_config_dir()
	-- 检查是否存在 .git 目录
	if vim.fn.isdirectory(config_dir .. "/.git") == 0 then return end

	git_fetch(function()
		local info = M.get_git_info()
		if info.error then return end

		if info.remote_hash ~= "" and info.local_hash ~= info.remote_hash then
			vim.notify("检测到配置更新！\nRemote: " .. info.remote_hash .. "\n按 <leader>pv 查看详情", vim.log.levels.INFO)
		end
	end)
end

-- 创建浮动窗口显示信息
local function create_floating_window(lines, can_update)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	-- 计算宽高
	local width = 0
	for _, line in ipairs(lines) do
		local len = vim.fn.strwidth(line)
		if len > width then width = len end
	end
	width = math.min(width + 4, vim.o.columns - 4)
	local height = #lines + 2

	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		row = row,
		col = col,
		width = width,
		height = height,
		border = "rounded",
		style = "minimal",
		noautocmd = true,
	})

	-- 设置高亮
	vim.api.nvim_win_set_option(win, "winhl", "Normal:NormalFloat,FloatBorder:FloatBorder")
	
	-- 键位映射
	local close_keys = { "q", "<Esc>" }
	for _, key in ipairs(close_keys) do
		vim.keymap.set("n", key, function()
			if vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_close(win, true)
			end
		end, { buffer = buf, nowait = true })
	end

	if can_update then
		vim.keymap.set("n", "u", function()
			if vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_close(win, true)
			end
			M.perform_update()
		end, { buffer = buf, nowait = true, desc = "Update" })
		
vim.keymap.set("n", "<CR>", function()
			if vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_close(win, true)
			end
			M.perform_update()
		end, { buffer = buf, nowait = true, desc = "Update" })
	end
end

-- 显示版本信息
function M.show_version_info()
	vim.notify("正在检查更新...", vim.log.levels.INFO)

	git_fetch(function()
		local info = M.get_git_info()

		if info.error then
			vim.notify(info.error, vim.log.levels.WARN)
			return
		end

		local lines = {}
		table.insert(lines, "Config Version Info")
		table.insert(lines, "--------------------")
		table.insert(lines, "Config Path: " .. info.config_path)
		table.insert(lines, "Remote URL : " .. info.remote_url)
		table.insert(lines, "")
		table.insert(lines, string.format("Local : %s (%s)", info.local_hash, info.local_time))

		if info.remote_hash ~= "" then
			table.insert(lines, string.format("Remote: %s (%s)", info.remote_hash, info.remote_time))
		else
			table.insert(lines, "Remote: (Unknown/Not fetched)")
		end
		table.insert(lines, "")

		local can_update = false
		local status_msg = ""

		if info.is_dirty then
			status_msg = "⚠️  本地有未提交的更改 (Dirty)"
		elseif info.remote_hash == "" then
			status_msg = "❓ 无法获取远程信息"
		elseif info.local_hash == info.remote_hash then
			status_msg = "✅ 已是最新版本 (Up-to-date)"
		else
			local divergence = exec_git("rev-list --left-right --count HEAD...origin/master", info.config_path)
			local behind = tonumber(divergence:match("%d+%s+(%d+)")) or 0
			local ahead = tonumber(divergence:match("(%d+)%s+%d+")) or 0

			if ahead > 0 then
				status_msg = string.format("⚠️  本地领先远程 %d 个提交 (Diverged)", ahead)
			elseif behind > 0 then
				status_msg = string.format("⬇️  落后远程 %d 个提交 (可更新)", behind)
				can_update = true
			else
				status_msg = "✅ 已是最新版本"
			end
		end

		table.insert(lines, "Status: " .. status_msg)
		table.insert(lines, "")
		table.insert(lines, "--------------------")
		
		if can_update then
			table.insert(lines, "Press 'u' or <Enter> to Update")
			table.insert(lines, "Press 'q' or <Esc> to Close")
		else
			table.insert(lines, "Press 'q' or <Esc> to Close")
		end

		vim.schedule(function()
			create_floating_window(lines, can_update)
		end)
	end)
end

-- 执行更新
function M.perform_update()
	local config_dir = get_config_dir()
	vim.notify("正在更新配置...", vim.log.levels.INFO)
	vim.fn.jobstart({ "git", "pull", "origin", "master" }, {
		cwd = config_dir,
		on_exit = function(_, code) 
			if code == 0 then
				vim.notify("配置更新成功！建议重启 Neovim。", vim.log.levels.INFO)
			else
				vim.notify("配置更新失败 (Exit code " .. code .. ")。请检查 git 状态。", vim.log.levels.ERROR)
			end
		end,
	})
end

return M
