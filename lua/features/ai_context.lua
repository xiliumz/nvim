return {
	plugins = { "context.nvim" },
	setup = function()
		local context = require("context")
		context.setup({
			picker = context.pickers.telescope,
			prompts = {
				explain = "Explain {this}",
				fix = "Fix the issue at {position}",
				review = "Review {file} for issues",
			},
		})
		vim.keymap.set({ "n", "v" }, "<leader>a", function()
			require("context").pick()
		end, { desc = "Context" })
	end,
}
