-- lua/config/codecompanion.lua
-- CodeCompanion AI 助手配置。Codex 通过 ACP adapter 接入 Chat，并通过 CLI interaction 接入终端式交互。

local adapters = require("codecompanion.adapters")

local codex_config_file = vim.fn.expand("~/.codex/config.toml")
local codex_auth_file = vim.fn.expand("~/.codex/auth.json")

local auth_methods = {
	{ label = "Codex 本地配置/自定义提供商", value = "openai-api-key" },
	{ label = "ChatGPT 官方登录态", value = "chatgpt" },
	{ label = "CODEX_API_KEY", value = "codex-api-key" },
}
local auth_labels = {}
for _, method in ipairs(auth_methods) do
	auth_labels[method.value] = method.label
end

local state_file = vim.fn.stdpath("state") .. "/codecompanion/codex-auth.json"

local codex_command = { "npx", "-y", "@zed-industries/codex-acp" }
if vim.fn.executable("codex-acp") == 1 then
	codex_command = { "codex-acp" }
end

local ai_status = {
	chat = "idle",
	cli = "idle",
	requests = 0,
	tools = "idle",
	tool = nil,
	approval = nil,
	last = nil,
}
_G.moevim_codecompanion_status = ai_status

local function read_file(path)
	local file = io.open(path, "r")
	if not file then
		return nil
	end

	local content = file:read("*a")
	file:close()
	return content
end

local function codex_config_value(key)
	local content = read_file(codex_config_file)
	if not content then
		return nil
	end

	return content:match(key .. '%s*=%s*"([^"]+)"')
end

local function codex_uses_custom_provider()
	local provider = codex_config_value("model_provider")
	return provider ~= nil and provider ~= "openai"
end

local function read_codex_openai_api_key()
	if vim.env.OPENAI_API_KEY and vim.env.OPENAI_API_KEY ~= "" then
		return vim.env.OPENAI_API_KEY
	end

	local content = read_file(codex_auth_file)
	if not content then
		return nil
	end

	local ok, data = pcall(vim.json.decode, content)
	if ok and type(data) == "table" and type(data.OPENAI_API_KEY) == "string" and data.OPENAI_API_KEY ~= "" then
		return data.OPENAI_API_KEY
	end
	return nil
end

local function has_credentials(method)
	if method == "openai-api-key" then
		return read_codex_openai_api_key() ~= nil
	end
	if method == "codex-api-key" then
		return vim.env.CODEX_API_KEY ~= nil and vim.env.CODEX_API_KEY ~= ""
	end
	return true
end

local function read_auth_method()
	if vim.env.CODECOMPANION_CODEX_AUTH_METHOD and auth_labels[vim.env.CODECOMPANION_CODEX_AUTH_METHOD] then
		return vim.env.CODECOMPANION_CODEX_AUTH_METHOD
	end

	local content = read_file(state_file)
	if not content then
		return nil
	end

	local ok, data = pcall(vim.json.decode, content)
	if ok and type(data) == "table" and auth_labels[data.auth_method] then
		if data.auth_method == "chatgpt" and codex_uses_custom_provider() then
			return nil
		end
		return data.auth_method
	end
	return nil
end

local function write_auth_method(method)
	vim.fn.mkdir(vim.fn.fnamemodify(state_file, ":h"), "p")

	local file = assert(io.open(state_file, "w"))
	file:write(vim.json.encode({ auth_method = method }))
	file:close()
end

local function select_auth_method(callback)
	vim.ui.select(auth_methods, {
		prompt = "选择 Codex 登录方式",
		format_item = function(item)
			return item.label
		end,
	}, function(choice)
		if not choice then
			return
		end

		write_auth_method(choice.value)
		vim.notify("Codex 登录方式: " .. choice.label, vim.log.levels.INFO)

		if callback then
			callback(choice.value)
		end
	end)
end

local function ensure_auth_method(callback)
	local method = read_auth_method()
	if method then
		if not has_credentials(method) then
			vim.notify("当前 Codex 登录方式缺少凭据，请重新选择", vim.log.levels.WARN)
			select_auth_method(callback)
			return
		end

		callback(method)
		return
	end

	select_auth_method(callback)
end

local function codex_cli_available()
	if vim.fn.executable("codex") == 1 then
		return true
	end

	vim.notify("未找到 codex CLI，无法打开 CodeCompanion CLI interaction", vim.log.levels.ERROR)
	return false
end

local function status_state()
	if ai_status.requests > 0 then
		return "running"
	end
	if ai_status.tools ~= "idle" then
		return ai_status.tools
	end
	return ai_status.chat
end

local function status_lines()
	local lines = {
		"AI: " .. status_state(),
		"Chat: " .. ai_status.chat,
		"CLI: " .. ai_status.cli,
		"Tools: " .. ai_status.tools .. (ai_status.tool and (" (" .. ai_status.tool .. ")") or ""),
	}

	local ok, codecompanion = pcall(require, "codecompanion")
	if ok then
		local chat = codecompanion.last_chat()
		if chat then
			table.insert(lines, "Chat buffer: " .. chat.bufnr)
			if chat.title then
				table.insert(lines, "Title: " .. chat.title)
			end
			if chat.acp_connection and chat.acp_connection.session_id then
				table.insert(lines, "ACP session: " .. chat.acp_connection.session_id)
			end
		end
	end

	local metadata = rawget(_G, "codecompanion_chat_metadata")
	if metadata then
		for bufnr, meta in pairs(metadata) do
			local adapter = meta.adapter or {}
			table.insert(
				lines,
				string.format(
					"Buf %s: %s %s, cycles=%s, context=%s",
					bufnr,
					adapter.name or "unknown",
					adapter.model or "",
					meta.cycles or 0,
					meta.context_items or 0
				)
			)
		end
	end

	local cli_metadata = rawget(_G, "codecompanion_cli_metadata")
	if cli_metadata then
		for bufnr, meta in pairs(cli_metadata) do
			table.insert(lines, string.format("CLI %s: %s running=%s", bufnr, meta.agent or "unknown", meta.running))
		end
	end

	if ai_status.approval then
		table.insert(lines, "Approval: " .. ai_status.approval)
	end
	if ai_status.last then
		table.insert(lines, "Last: " .. ai_status.last)
	end

	return lines
end

local function show_status()
	vim.notify(table.concat(status_lines(), "\n"), vim.log.levels.INFO, { title = "CodeCompanion" })
end

function _G.moevim_codecompanion_statusline()
	local state = status_state()
	if state == "idle" then
		return ""
	end
	return " AI:" .. state .. " "
end

local function setup_status_events()
	local group = vim.api.nvim_create_augroup("MoevimCodeCompanionStatus", { clear = true })

	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "CodeCompanion*",
		callback = function(event)
			local data = event.data or {}

			if event.match == "CodeCompanionChatSubmitted" then
				ai_status.chat = "submitted"
			elseif event.match == "CodeCompanionChatDone" then
				ai_status.chat = "idle"
				ai_status.last = "chat done"
			elseif event.match == "CodeCompanionChatStopped" then
				ai_status.chat = "stopped"
				ai_status.requests = 0
				ai_status.last = "chat stopped"
			elseif event.match == "CodeCompanionACPConnected" then
				ai_status.chat = "connected"
				ai_status.last = "ACP connected"
			elseif event.match == "CodeCompanionACPChatRestored" then
				ai_status.chat = "restored"
				ai_status.last = "restored " .. (data.title or data.session_id or "session")
			elseif event.match == "CodeCompanionCLICreated" or event.match == "CodeCompanionCLIOpened" then
				ai_status.cli = "running"
			elseif event.match == "CodeCompanionCLIClosed" then
				ai_status.cli = "closed"
			elseif event.match == "CodeCompanionCLISent" then
				ai_status.cli = "sent"
				ai_status.last = "CLI prompt sent"
			elseif event.match == "CodeCompanionToolsStarted" then
				ai_status.tools = "running"
			elseif event.match == "CodeCompanionToolsFinished" then
				ai_status.tools = "idle"
				ai_status.tool = nil
			elseif event.match == "CodeCompanionToolStarted" then
				ai_status.tools = "running"
				ai_status.tool = data.tool or data.name
			elseif event.match == "CodeCompanionToolFinished" then
				ai_status.tool = nil
			elseif event.match == "CodeCompanionToolApprovalRequested" then
				ai_status.approval = data.name or "requested"
			elseif event.match == "CodeCompanionToolApprovalFinished" then
				ai_status.approval = nil
			elseif event.match == "CodeCompanionRequestStarted" then
				ai_status.requests = ai_status.requests + 1
				ai_status.chat = data.interaction or "request"
			elseif event.match == "CodeCompanionRequestStreaming" then
				ai_status.chat = "streaming"
			elseif event.match == "CodeCompanionRequestFinished" then
				ai_status.requests = math.max(ai_status.requests - 1, 0)
				if ai_status.requests == 0 then
					ai_status.chat = "idle"
				end
				ai_status.last = "request " .. (data.status or "finished")
			end

			vim.cmd.redrawstatus()
		end,
	})
end

local function resume_codex_session()
	ensure_auth_method(function()
		local codecompanion = require("codecompanion")
		local chat = codecompanion.chat()
		if not chat then
			return vim.notify("无法创建 Codex Chat", vim.log.levels.ERROR)
		end

		chat.ui:open()

		local acp_handler = require("codecompanion.interactions.chat.acp.handler").new(chat)
		if not acp_handler:ensure_connection() then
			return vim.notify("Codex ACP 连接失败，无法恢复会话", vim.log.levels.ERROR)
		end

		require("codecompanion.interactions.chat.slash_commands").run({
			label = "/resume",
			config = require("codecompanion.config").interactions.chat.slash_commands.resume,
			context = {},
		}, chat)
	end)
end

local function filter_codex_warning(content)
	local filtered, count = content:gsub(
		"Model metadata for `[^`]+` not found%. Defaulting to fallback metadata; this can degrade performance and cause issues%.%s*",
		""
	)
	return filtered, count
end

local function patch_acp_handler()
	local handler = require("codecompanion.interactions.chat.acp.handler")
	if handler._moevim_codex_warning_filter then
		return
	end

	local original_handle_message_chunk = handler.handle_message_chunk
	function handler:handle_message_chunk(content)
		if self.chat.adapter and self.chat.adapter.name == "codex" then
			if self._moevim_codex_warning_prefix then
				content = self._moevim_codex_warning_prefix .. content
				self._moevim_codex_warning_prefix = nil
			end

			local filtered, count = filter_codex_warning(content)
			if count == 0 and content:match("^Model metadata for `") then
				self._moevim_codex_warning_prefix = content
				return
			end

			content = filtered
			if content == "" then
				return
			end
		end

		return original_handle_message_chunk(self, content)
	end

	handler._moevim_codex_warning_filter = true
end

require("codecompanion").setup({
	adapters = {
		acp = {
			codex = function()
				return adapters.extend("codex", {
					commands = {
						default = codex_command,
					},
					defaults = {
						auth_method = read_auth_method() or "openai-api-key",
						timeout = 10000,
					},
					env = {
						CODEX_API_KEY = function()
							return vim.env.CODEX_API_KEY or ""
						end,
						OPENAI_API_KEY = function()
							return read_codex_openai_api_key() or ""
						end,
					},
				})
			end,
		},
	},
	display = {
		action_palette = {
			provider = "telescope",
		},
		chat = {
			intro_message = "Codex Chat: <C-s> 发送，? 查看按键，/resume 恢复会话，\\ 触发 Codex 命令补全",
			start_in_insert_mode = true,
			window = {
				position = "right",
				width = 0.4,
			},
		},
		cli = {
			window = {
				position = "right",
				width = 0.4,
			},
		},
		input = {
			window = {
				width = { min = 50, max = 80 },
				height = { min = 4, max = 8 },
			},
		},
	},
	interactions = {
		chat = {
			adapter = "codex",
			opts = {
				completion_provider = "blink",
			},
		},
		cli = {
			agent = "codex",
			agents = {
				codex = {
					cmd = "codex",
					args = {},
					description = "OpenAI Codex CLI",
					provider = "terminal",
				},
			},
			opts = {
				auto_insert = true,
			},
		},
	},
})

patch_acp_handler()
setup_status_events()

vim.api.nvim_create_user_command("CodeCompanionCodexAuth", function()
	select_auth_method()
end, { desc = "重新选择 CodeCompanion Codex 登录方式" })

vim.api.nvim_create_user_command("CodeCompanionCodexResume", function()
	resume_codex_session()
end, { desc = "恢复 Codex ACP 会话" })

vim.api.nvim_create_user_command("CodeCompanionCodexCLI", function()
	if codex_cli_available() then
		require("codecompanion").toggle_cli({ agent = "codex" })
	end
end, { desc = "切换 Codex CLI" })

vim.api.nvim_create_user_command("CodeCompanionStatus", function()
	show_status()
end, { desc = "显示 CodeCompanion 状态" })

vim.keymap.set({ "n", "v" }, "<leader>aa", "<cmd>CodeCompanionActions<CR>", { desc = "AI 动作面板" })
vim.keymap.set("n", "<leader>ac", function()
	ensure_auth_method(function()
		vim.cmd("CodeCompanionChat Toggle")
	end)
end, { desc = "切换 Codex Chat" })
vim.keymap.set("v", "<leader>ac", function()
	ensure_auth_method(function()
		vim.cmd("CodeCompanionChat Add")
	end)
end, { desc = "添加选区到 AI Chat" })
vim.keymap.set("n", "<leader>ar", "<cmd>CodeCompanionCodexResume<CR>", { desc = "恢复 Codex 会话" })
vim.keymap.set("n", "<leader>at", "<cmd>CodeCompanionCodexCLI<CR>", { desc = "切换 Codex CLI" })
vim.keymap.set({ "n", "v" }, "<leader>ap", function()
	if codex_cli_available() then
		require("codecompanion").cli({ agent = "codex", prompt = true })
	end
end, { desc = "向 Codex CLI 提问" })
vim.keymap.set({ "n", "v" }, "<leader>ai", function()
	if codex_cli_available() then
		require("codecompanion").cli("#{this}", { agent = "codex", focus = false })
	end
end, { desc = "发送当前上下文到 Codex CLI" })
vim.keymap.set("n", "<leader>ad", function()
	if codex_cli_available() then
		require("codecompanion").cli(
			"#{diagnostics} 请修复这些诊断。",
			{ agent = "codex", focus = false, submit = true }
		)
	end
end, { desc = "发送诊断到 Codex CLI" })
vim.keymap.set("n", "<leader>as", show_status, { desc = "显示 AI 状态" })
vim.keymap.set("n", "<leader>al", "<cmd>CodeCompanionCodexAuth<CR>", { desc = "选择 Codex 登录方式" })
