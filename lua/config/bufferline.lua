-- lua/config/bufferline.lua
-- nvim-bufferline 配置

require("bufferline").setup({
	options = {
		mode = "buffers", -- "buffers" 或 "tabs"
		numbers = "ordinal", -- "none" | "ordinal" | "buffer_id" | "both" | function
		-- indicator = {
		-- 	icon = "▎",
		-- 	style = "icon",
		-- },
		buffer_close_icon = "X",
		modified_icon = "●",
		close_icon = "X",
		left_trunc_icon = "",
		right_trunc_icon = "",
		-- show_buffer_close_icons = true,
		-- show_close_icon = true,
		show_duplicate_buffers = false,
		diagnostics = "nvim_lsp", -- "nvim_lsp" | "coc" | "default"
		-- diagnostics_indicator = function(count, level, diagnostics_dict, context)
		-- 	local s = " "
		-- 	for e_level, e_count in pairs(diagnostics_dict) do
		-- 		s = s .. context.icons[e_level] .. e_count
		-- 	end
		-- 	return s
		-- end,
		-- offsets = { { filetype = "NvimTree", text = "File Explorer", text_align = "left" } },
		-- color_icons = true,
		show_buffer_icons = true,
		hover = {
			enabled = true,
			delay = 200,
			reveal = { "close" },
		},
		sort_by = "insert_after_current", -- "id" | "name" | "extension" | "relative_directory" | "tabs" | "lsp_uri" | "insert_after_current"

	},
	highlights = {
		-- custom highlights for bufferline
	}
})
