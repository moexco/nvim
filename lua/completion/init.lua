local cmp = require("cmp")
local luasnip = require("luasnip")

luasnip.setup({
	region_check_events = "InsertEnter,CursorMoved",
	delete_check_events = "TextChanged",
})

-- Updated kind_icons for better representation
local kind_icons = {
	Text = " ",
	Method = " ",
	Function = " ",
	Constructor = " ",
	Field = " ",
	Variable = " ",
	Class = " ",
	Interface = " ",
	Module = " ",
	Property = " ",
	Unit = " ",
	Value = " ",
	Enum = " ",
	Keyword = " ",
	Snippet = " ",
	Color = " ",
	File = " ",
	Reference = " ",
	Folder = " ",
	EnumMember = " ",
	Constant = " ",
	Struct = " ",
	Event = " ",
	Operator = " ",
	TypeParameter = " ",
}

cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	window = {
		completion = {
			max_height = 5, -- 限制补全列表显示的最大高度为 5
			border = 'rounded', -- 添加圆角边框
		},
		documentation = { -- 也为文档窗口添加边框以保持一致性
			border = 'rounded',
		},
	},
	formatting = {
		fields = { "abbr", "kind", "menu" }, -- 调整顺序，abbr在前
		format = function(entry, vim_item)
			local max_abbr_width = 30 -- 设置 abbr 的最大显示宽度

			-- 截断 abbr 并添加省略号
			if #vim_item.abbr > max_abbr_width then
				vim_item.abbr = string.sub(vim_item.abbr, 1, max_abbr_width - 3) .. "..."
			end

			local kind_text = entry.data and entry.data.detail or vim_item.kind

			-- 添加类型图标和名称
			-- kind_icons[vim_item.kind] 此时为 " "，所以这里会显示 " KindName" 或 " TypeDetail"
			vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind], kind_text)

			-- 添加来源信息
			vim_item.menu = ({
				nvim_lsp = "[LSP]",
				luasnip = "[Snippet]",
				buffer = "[Buffer]",
				path = "[Path]",
			})[entry.source.name]

			-- 格式化最终显示的字符串，将 kind 和 menu 放在 abbr 后面
			-- 使用一个空格作为分隔，确保视觉上的分离
			vim_item.menu = (vim_item.menu and " " .. vim_item.menu or "")
			vim_item.kind = (vim_item.kind and " " .. vim_item.kind or "")

			return vim_item
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
		["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
		["<C-j>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<C-k>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
		["<Tab>"] = cmp.mapping(function(fallback)
			if luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "buffer" },
		{ name = "path" },
	}),
})
