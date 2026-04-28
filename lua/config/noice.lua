-- lua/config/noice.lua
-- Noice.nvim 插件配置 (UI美化)

require("noice").setup({
	lsp = {
		progress = {
			enabled = true,
			view = "mini",
		},
		hover = {
			enabled = false,
		},
		signature = {
			enabled = false,
		},
	},
	presets = {
		bottom_search = true,
		command_palette = true,
		long_message_to_split = true,
		inc_rename = false,
		lsp_doc_border = true,
	},
})

local ok, treesitter = pcall(require, "noice.text.treesitter")
if ok then
	local has_lang = treesitter.has_lang
	treesitter.has_lang = function(lang)
		if lang == "vim" then
			return false
		end
		return has_lang(lang)
	end
end
