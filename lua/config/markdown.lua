-- lua/config/markdown.lua
-- Markdown 渲染和图片支持配置

-- render-markdown 配置
-- https://github.com/MeanderingProgrammer/render-markdown.nvim
require("render-markdown").setup({
	-- 启用文件类型
	file_types = { "markdown" },
	-- 可以在这里配置标题符号、高亮等，默认配置通常已足够美观
    latex = { enabled = false }, -- 默认禁用 latex 以防报错，除非已配置
})

-- image.nvim 配置
-- https://github.com/3rd/image.nvim
-- 注意：此插件需要系统安装 ImageMagick (例如: sudo apt install imagemagick libmagickwand-dev)
-- 并且可能需要 Lua 的 magick 绑定。
local status_ok, image = pcall(require, "image")
if status_ok then
	image.setup({
		-- backend = "kitty", -- 默认自动检测，支持 kitty, ueberzug, etc.
		integrations = {
			markdown = {
				enabled = true,
				clear_in_insert_mode = false,
				download_remote_images = true,
				only_render_image_at_cursor = false,
				filetypes = { "markdown", "vimwiki" },
			},
		},
		max_width = nil,
		max_height = nil,
		max_width_window_percentage = nil,
		max_height_window_percentage = 50,
		window_overlap_clear_enabled = false,
		editor_only_render_when_focused = false,
		hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp" },
	})
end
