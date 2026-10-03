return {
	plugins = { "guess-indent.nvim", "neoscroll.nvim", "mini.nvim", "plenary.nvim", "todo-comments.nvim" },
	setup = function()
		require("guess-indent").setup({})
		require("neoscroll").setup({})
		require("mini.ai").setup({
			n_lines = 200,
		})
		require("mini.surround").setup()

		require("todo-comments").setup({})
	end,
}
