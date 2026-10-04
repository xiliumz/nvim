return {
	plugins = { "nvim-web-devicons", "fyler.nvim" },
	setup = function()
		require("fyler").setup({
			integrations = {
				icon = "nvim_web_devicons",
			},
		})
		vim.keymap.set("n", "<leader>e", "<cmd>Fyler<cr>", { desc = "Open Fyler View" })
	end,
}
