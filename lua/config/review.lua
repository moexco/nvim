-- lua/config/review.lua
-- Review Mode: optimized for reading diffs and code context.

local M = {
	enabled = false,
	state = nil,
}

local function with_gitsigns(callback)
	pcall(require, "config.gitsigns")
	local ok, gitsigns = pcall(require, "gitsigns")
	if ok then
		callback(gitsigns)
	end
end

local function get_gitsigns_blame_state()
	local ok, config = pcall(require, "gitsigns.config")
	if ok and config.config then
		return config.config.current_line_blame
	end
	return nil
end

function M.enable()
	if M.enabled then
		return
	end

	M.state = {
		cursorline = vim.wo.cursorline,
		cursorlineopt = vim.wo.cursorlineopt,
		diagnostic = vim.deepcopy(vim.diagnostic.config()),
		current_line_blame = get_gitsigns_blame_state(),
	}

	M.enabled = true
	vim.g.moevim_review_mode = true

	vim.wo.cursorline = true
	vim.wo.cursorlineopt = "number"
	vim.diagnostic.config({
		virtual_text = false,
		virtual_lines = false,
		underline = false,
	})

	pcall(require, "config.gitsigns")
	pcall(vim.cmd, "GitFilePreviewEnable")
	with_gitsigns(function(gitsigns)
		gitsigns.toggle_current_line_blame(true)
	end)

	vim.notify("Review Mode: enabled", vim.log.levels.INFO)
end

function M.disable()
	if not M.enabled then
		return
	end

	local state = M.state or {}
	M.enabled = false
	M.state = nil
	vim.g.moevim_review_mode = false

	pcall(require, "config.gitsigns")
	pcall(vim.cmd, "GitFilePreviewDisable")
	with_gitsigns(function(gitsigns)
		if state.current_line_blame ~= nil then
			gitsigns.toggle_current_line_blame(state.current_line_blame)
		else
			gitsigns.toggle_current_line_blame(false)
		end
	end)

	if state.cursorline ~= nil then
		vim.wo.cursorline = state.cursorline
	end
	if state.cursorlineopt ~= nil then
		vim.wo.cursorlineopt = state.cursorlineopt
	end
	if state.diagnostic then
		vim.diagnostic.config(state.diagnostic)
	end

	vim.notify("Review Mode: disabled", vim.log.levels.INFO)
end

function M.toggle()
	if M.enabled then
		M.disable()
	else
		M.enable()
	end
end

vim.api.nvim_create_user_command("ReviewModeEnable", M.enable, { desc = "Enable Review Mode" })
vim.api.nvim_create_user_command("ReviewModeDisable", M.disable, { desc = "Disable Review Mode" })
vim.api.nvim_create_user_command("ReviewModeToggle", M.toggle, { desc = "Toggle Review Mode" })

vim.keymap.set("n", "<leader>vr", M.toggle, { desc = "切换 Review Mode", silent = true })

return M
