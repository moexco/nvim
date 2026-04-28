require("blink.cmp").setup({
	keymap = {
		preset = "none",
		["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
		["<C-e>"] = { "hide", "fallback" },
		["<CR>"] = { "accept", "fallback" },
		["<C-n>"] = {
			function(cmp)
				return cmp.select_next({ auto_insert = false })
			end,
			"fallback_to_mappings",
		},
		["<C-p>"] = {
			function(cmp)
				return cmp.select_prev({ auto_insert = false })
			end,
			"fallback_to_mappings",
		},
		["<C-j>"] = { "select_next", "snippet_forward", "fallback" },
		["<C-k>"] = { "select_prev", "snippet_backward", "fallback" },
		["<C-b>"] = { "scroll_documentation_up", "fallback" },
		["<C-f>"] = { "scroll_documentation_down", "fallback" },
		["<Tab>"] = { "snippet_forward", "fallback" },
		["<S-Tab>"] = { "snippet_backward", "fallback" },
	},
	appearance = {
		nerd_font_variant = "mono",
	},
	completion = {
		list = {
			selection = {
				preselect = true,
				auto_insert = false,
			},
		},
		menu = {
			border = "rounded",
			max_height = 5,
		},
		documentation = {
			auto_show = true,
			auto_show_delay_ms = 200,
			window = {
				border = "rounded",
			},
		},
	},
	sources = {
		default = { "lsp", "snippets", "path", "buffer" },
	},
	snippets = {
		preset = "default",
	},
	signature = {
		enabled = true,
		window = {
			border = "rounded",
		},
	},
	fuzzy = {
		implementation = "lua",
	},
})
