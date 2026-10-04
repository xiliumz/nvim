return {
	plugins = { "image.nvim" },
	setup = function()
		require("image").setup({
			processor = "magick_cli",
			integrations = {
				markdown = {
					enabled = false,
				},
			},
		})
	end,
}
