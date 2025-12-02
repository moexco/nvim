local luasnip = require("luasnip")

luasnip.setup({
	region_check_events = "InsertEnter,CursorMoved",
	delete_check_events = "TextChanged",
})
