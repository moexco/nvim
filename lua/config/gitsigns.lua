-- lua/config/gitsigns.lua
-- Gitsigns 插件快捷键配置

local function gitsigns_action(action)
	return function(...)
		return require("gitsigns")[action](...)
	end
end

local function selected_range()
	local start_line = vim.fn.line("v")
	local end_line = vim.fn.line(".")
	if start_line > end_line then
		start_line, end_line = end_line, start_line
	end
	return { start_line, end_line }
end

local function map(mode, lhs, rhs, desc, opts)
	opts = vim.tbl_extend("force", { desc = desc, silent = true }, opts or {})
	vim.keymap.set(mode, lhs, rhs, opts)
end

local function setup_file_preview_highlights()
	vim.api.nvim_set_hl(0, "MoevimGitPreviewAddLine", { bg = "#263b31" })
	vim.api.nvim_set_hl(0, "MoevimGitPreviewChangeLine", { bg = "#233244" })
	vim.api.nvim_set_hl(0, "MoevimGitPreviewDeleteLine", { bg = "#4a2830" })
	vim.api.nvim_set_hl(0, "MoevimGitPreviewAddText", { fg = "#50fa7b", bold = true })
	vim.api.nvim_set_hl(0, "MoevimGitPreviewChangeText", { fg = "#8be9fd", bold = true })
	vim.api.nvim_set_hl(0, "MoevimGitPreviewDeleteText", { fg = "#ff6e6e", bold = true })
	vim.api.nvim_set_hl(0, "MoevimGitPreviewAddVirt", { fg = "#50fa7b", bg = "#263b31" })
	vim.api.nvim_set_hl(0, "MoevimGitPreviewChangeVirt", { fg = "#8be9fd", bg = "#233244" })
	vim.api.nvim_set_hl(0, "MoevimGitPreviewDeleteVirt", { fg = "#ff6e6e", bg = "#4a2830" })
end

local file_preview_ns = vim.api.nvim_create_namespace("moevim_gitsigns_file_preview")

local function clear_file_preview(bufnr)
	vim.api.nvim_buf_clear_namespace(bufnr, file_preview_ns, 0, -1)
end

local function has_file_preview(bufnr)
	return #vim.api.nvim_buf_get_extmarks(bufnr, file_preview_ns, 0, -1, { limit = 1 }) > 0
end

local function hunk_preview_style(hunk)
	if hunk.added.count == 0 and hunk.removed.count > 0 then
		return "MoevimGitPreviewDeleteLine", "MoevimGitPreviewDeleteText", "MoevimGitPreviewDeleteVirt", "-"
	end
	if hunk.added.count > 0 and hunk.removed.count == 0 then
		return "MoevimGitPreviewAddLine", "MoevimGitPreviewAddText", "MoevimGitPreviewAddVirt", "+"
	end
	return "MoevimGitPreviewChangeLine", "MoevimGitPreviewChangeText", "MoevimGitPreviewChangeVirt", "~"
end

local function virtual_line(text, hl)
	local padding = math.max(1, vim.o.columns - vim.fn.strdisplaywidth(text))
	return { { text, hl }, { string.rep(" ", padding), hl } }
end

local function toggle_file_preview()
	setup_file_preview_highlights()

	local bufnr = vim.api.nvim_get_current_buf()
	if has_file_preview(bufnr) then
		clear_file_preview(bufnr)
		return
	end

	local hunks = require("gitsigns").get_hunks(bufnr)
	if not hunks or vim.tbl_isempty(hunks) then
		vim.notify("No Git hunks in current file", vim.log.levels.INFO)
		return
	end

	local line_count = vim.api.nvim_buf_line_count(bufnr)
	for _, hunk in ipairs(hunks) do
		local line_hl, text_hl, virt_hl, hunk_mark = hunk_preview_style(hunk)
		if hunk.added.count > 0 then
			local start_row = math.max(hunk.added.start - 1, 0)
			local end_row = math.min(start_row + hunk.added.count - 1, line_count - 1)
			for row = start_row, end_row do
				vim.api.nvim_buf_set_extmark(bufnr, file_preview_ns, row, 0, {
					sign_text = hunk_mark,
					sign_hl_group = text_hl,
					line_hl_group = line_hl,
					priority = 1000,
				})
			end
		end

		local removed_lines = {}
		for _, line in ipairs(hunk.lines or {}) do
			if line:sub(1, 1) == "-" then
				table.insert(removed_lines, virtual_line(hunk_mark .. " " .. line:sub(2), virt_hl))
			end
		end

		if #removed_lines > 0 then
			local row = hunk.added.start > 0 and hunk.added.start - 1 or 0
			row = math.max(0, math.min(row, line_count - 1))
			vim.api.nvim_buf_set_extmark(bufnr, file_preview_ns, row, 0, {
				virt_lines = removed_lines,
				virt_lines_above = true,
				virt_lines_leftcol = true,
			})
		end
	end
end

map("n", "]g", function()
	if vim.wo.diff then
		vim.cmd("normal! ]c")
		return
	end
	require("gitsigns").nav_hunk("next")
end, "下一个 Git hunk")

map("n", "[g", function()
	if vim.wo.diff then
		vim.cmd("normal! [c")
		return
	end
	require("gitsigns").nav_hunk("prev")
end, "上一个 Git hunk")

map("n", "<leader>gs", gitsigns_action("stage_hunk"), "暂存当前修改块")
map("v", "<leader>gs", function()
	require("gitsigns").stage_hunk(selected_range())
end, "暂存选中修改")

map("n", "<leader>gr", gitsigns_action("reset_hunk"), "回滚当前修改块")
map("v", "<leader>gr", function()
	require("gitsigns").reset_hunk(selected_range())
end, "回滚选中修改")

map("n", "<leader>gp", gitsigns_action("preview_hunk"), "预览当前修改块")
map("n", "<leader>gP", toggle_file_preview, "切换当前文件差异预览")
map("n", "<leader>gb", gitsigns_action("blame_line"), "查看当前行归属")
map("n", "<leader>gB", gitsigns_action("toggle_current_line_blame"), "切换当前行归属")
map("n", "<leader>gw", gitsigns_action("toggle_word_diff"), "切换词级差异")
map({ "o", "x" }, "ih", gitsigns_action("select_hunk"), "选择 Git hunk")
map({ "o", "x" }, "ah", gitsigns_action("select_hunk"), "选择 Git hunk")

require("gitsigns").setup({
	current_line_blame_opts = {
		delay = 300,
	},
})
