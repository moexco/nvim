local M = {}

-- 检查插件健康状况
function M.check_health()
	vim.cmd("checkhealth")
end

-- 扫描并报告可能损坏的插件
-- 逻辑：检查 pack/*/opt/ 下的目录，如果只包含 .git 而没有其他文件，可能下载失败
function M.detect_broken_plugins()
	local pack_dir = vim.fn.stdpath("data") .. "/site/pack"
	local broken_list = {}

	-- 简单的文件系统遍历 (依赖于 Linux/Unix 命令 find，因为 Neovim 的 fs 库遍历较繁琐)
	-- 为了跨平台兼容性最好用 vim.loop (uv)，但这里为了简洁先假设环境
	local handle = io.popen('find "' .. pack_dir .. '" -mindepth 4 -maxdepth 4 -type d -name ".git"')
	if not handle then
		vim.notify("无法扫描插件目录", vim.log.levels.ERROR)
		return
	end

	for git_dir in handle:lines() do
		local plugin_dir = git_dir:sub(1, -6) -- 去掉 /.git
		-- 检查是否为空或只有 .git
		local file_count = 0
		local check_handle = io.popen('ls -A "' .. plugin_dir .. '"')
		if check_handle then
			for _ in check_handle:lines() do
				file_count = file_count + 1
			end
			check_handle:close()
		end

		-- 如果只有 .git (或者加上一些忽略文件)，认为损坏
		if file_count <= 1 then
			table.insert(broken_list, plugin_dir)
		end
	end
	handle:close()

	if #broken_list > 0 then
		local msg = "发现可能损坏的插件目录 (仅包含 .git):\n" .. table.concat(broken_list, "\n")
		local choice = vim.fn.confirm(msg .. "\n\n是否删除这些目录以触发重新下载？", "&Yes\n&No", 1)
		if choice == 1 then
			for _, dir in ipairs(broken_list) do
				vim.fn.delete(dir, "rf")
				vim.notify("已删除: " .. dir, vim.log.levels.INFO)
			end
			vim.notify("清理完成。请重启 Neovim 以重新下载插件。", vim.log.levels.WARN)
		end
	else
		vim.notify("未发现明显的损坏插件目录。", vim.log.levels.INFO)
	end
end

-- 暴力重装：删除整个插件目录
function M.reinstall_all()
	local install_path = vim.fn.stdpath("data") .. "/site/pack"
	local choice = vim.fn.confirm(
		"警告: 此操作将删除以下目录及其所有内容:\n" .. install_path .. "\n\n这会强制重新下载所有插件。确定继续吗？",
		"&Yes\n&No",
		2
	)
	if choice == 1 then
		vim.fn.delete(install_path, "rf")
		vim.notify("插件目录已清除。请立即重启 Neovim。", vim.log.levels.WARN)
	end
end

return M
