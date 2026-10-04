return {
	plugins = { "blink.cmp" },
	setup = function()
		require("blink.cmp").setup({
			keymap = {
				preset = "enter",
			},

			appearance = {
				nerd_font_variant = "mono",
			},

			completion = {
				documentation = { auto_show = true, auto_show_delay_ms = 500 },
			},

			sources = {
				default = { "lsp", "path" },
				providers = {
					lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
				},
			},

			snippets = { preset = "default" },

			fuzzy = { implementation = "lua" },

			signature = { enabled = true },
		})
	end,
}
