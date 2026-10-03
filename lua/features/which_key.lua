return {
	plugins = { "which-key.nvim" },
	setup = function()
		require("which-key").setup({
			delay = 0,
			icons = {
				mappings = vim.g.have_nerd_font,
			},

			spec = {
				{ "<leader>s", group = "[S]earch" },
				{ "<leader>t", group = "[T]erminal" },
			},
		})
	end,
}
