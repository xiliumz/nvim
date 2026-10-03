return {
	plugins = { "nvim-web-devicons", "bufferline.nvim" },
	setup = function()
		require("bufferline").setup({})

		vim.keymap.set("n", "<Tab>", ":BufferLineCycleNext<CR>", { desc = "Go To Next Tab" })
		vim.keymap.set("n", "<S-Tab>", ":BufferLineCyclePrev<CR>", { desc = "Go To Previous Tab" })
		vim.keymap.set("n", "<A-,>", "<Cmd>BufferLineMovePrev<CR>")
		vim.keymap.set("n", "<A-.>", "<Cmd>BufferLineMoveNext<CR>")
		vim.keymap.set("n", "<leader>d", ":bd<CR>", { desc = "Delete Buffer" })
		vim.keymap.set("n", "<leader>D", function()
			local current = vim.api.nvim_get_current_buf()
			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
				if buf ~= current and vim.api.nvim_buf_is_loaded(buf) then
					vim.api.nvim_buf_delete(buf, {})
				end
			end
		end, { desc = "Delete all buffers except current" })
		for i = 1, 9 do
			vim.keymap.set("n", "<leader>" .. i, function()
				vim.cmd("BufferLineGoToBuffer " .. i)
			end, {
				desc = "Go to buffer " .. i,
			})
		end
	end,
}
