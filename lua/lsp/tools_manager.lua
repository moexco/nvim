local M = {}

-- 定义支持的语言及其工具配置
-- type: "go" | "rustup"
-- 对于 "go"，pkg 是 go install 的路径
-- 对于 "rustup"，pkg 是 component 名称
local lang_tools = {
	go = {
		{ bin = "gopls", pkg = "golang.org/x/tools/gopls", type = "go" },
		{ bin = "gotests", pkg = "github.com/cweill/gotests/gotests", type = "go" },
		{ bin = "impl", pkg = "github.com/josharian/impl", type = "go" },
		{ bin = "golangci-lint", pkg = "github.com/golangci/golangci-lint/cmd/golangci-lint", type = "go" },
		{ bin = "goimports", pkg = "golang.org/x/tools/cmd/goimports", type = "go" },
	},
	rust = {
		{ bin = "rust-analyzer", pkg = "rust-analyzer", type = "rustup" },
		{ bin = "rustfmt", pkg = "rustfmt", type = "rustup" },
		{ bin = "cargo-clippy", pkg = "clippy", type = "rustup" }, -- binary name often checked via cargo subcommands, but executable might be cargo-clippy
	},
}

local function rustup_component_installed(component)
	local output = vim.fn.systemlist({ "rustup", "component", "list", "--installed" })
	if vim.v.shell_error ~= 0 then
		return false
	end

	for _, line in ipairs(output) do
		if line == component or line:match("^" .. vim.pesc(component) .. "%-") then
			return true
		end
	end

	return false
end

local function tool_installed(tool)
	if tool.type == "go" then
		return vim.fn.executable(tool.bin) == 1
	end

	if tool.type == "rustup" then
		return rustup_component_installed(tool.pkg)
	end

	return false
end

function M.setup()
	-- 通用命令，根据当前文件类型执行检查安装
	vim.api.nvim_create_user_command("LspInstallTools", function()
		M.check_and_install(vim.bo.filetype, true)
	end, { desc = "Check and install/update tools for current filetype" })
end

-- 获取指定语言的工具状态列表
function M.get_tool_status(filetype)
	local tools = lang_tools[filetype]
	if not tools then
		return {}
	end

	local status = {}
	for _, tool in ipairs(tools) do
		local installed = tool_installed(tool)
		table.insert(status, { name = tool.bin, installed = installed })
	end
	return status
end

function M.check_and_install(filetype, force_update)
	local tools = lang_tools[filetype]
	if not tools then
		if force_update then
			vim.notify("No tools configuration found for filetype: " .. filetype, vim.log.levels.WARN)
		end
		return
	end

	local missing = {}
	local to_install = {} -- 存储完整的工具对象以便区分安装方式

	for _, tool in ipairs(tools) do
		local is_missing = false
		if force_update then
			is_missing = true
		else
			if not tool_installed(tool) then
				is_missing = true
			end
		end

		if is_missing then
			table.insert(missing, tool.bin)
			table.insert(to_install, tool)
		end
	end

	if #missing == 0 then
		if force_update then
			vim.notify("All " .. filetype .. " tools are installed.", vim.log.levels.INFO)
		end
		return
	end

	local prompt = "Missing " .. filetype .. " tools detected. Install?"
	if force_update then
		prompt = "Update/Reinstall " .. filetype .. " tools?"
	end

	vim.ui.select({ "Yes", "No" }, {
		prompt = prompt .. " [" .. table.concat(missing, ", ") .. "]",
	}, function(choice)
		if choice == "Yes" then
			M.run_install(to_install)
		end
	end)
end

function M.run_install(tool_list)
	vim.notify("Installing tools in background...", vim.log.levels.INFO)

	for _, tool in ipairs(tool_list) do
		local cmd = {}
		if tool.type == "go" then
			cmd = { "go", "install", tool.pkg .. "@latest" }
		elseif tool.type == "rustup" then
			cmd = { "rustup", "component", "add", tool.pkg }
		end

		if #cmd > 0 then
			vim.fn.jobstart(cmd, {
				on_exit = function(_, code)
					if code == 0 then
						vim.notify("Installed: " .. tool.bin, vim.log.levels.INFO)
					else
						vim.notify("Failed to install: " .. tool.bin .. " (Exit code: " .. code .. ")", vim.log.levels.ERROR)
					end
				end,
			})
		end
	end
end

return M
