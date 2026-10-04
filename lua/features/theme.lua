return {
	plugins = { "monokai-pro.nvim" },
	setup = function()
		vim.api.nvim_create_autocmd("ColorScheme", {
			callback = function()
				vim.api.nvim_set_hl(0, "DiffAdd", { bg = "#27321d", fg = "#a9dc76" })
				vim.api.nvim_set_hl(0, "DiffChange", { bg = "#2d2a2e", fg = "#ffd866" })
				vim.api.nvim_set_hl(0, "DiffDelete", { bg = "#3b1f1f", fg = "#ff6188" })
				vim.api.nvim_set_hl(0, "DiffText", { fg = "#ffd866", bg = "#3a3a3a", bold = true })

				vim.api.nvim_set_hl(0, "DiffviewDiffAdd", { link = "DiffAdd" })
				vim.api.nvim_set_hl(0, "DiffviewDiffChange", { link = "DiffChange" })
				vim.api.nvim_set_hl(0, "DiffviewDiffDelete", { link = "DiffDelete" })
				vim.api.nvim_set_hl(0, "DiffviewDiffText", { link = "DiffText" })
			end,
		})
		require("monokai-pro").setup({
			transparent_background = true,
			filter = "spectrum",
			override = function()
				return {
					["@lsp.type.parameter"] = { link = "@variable.parameter" },
					["@lsp.typemod.variable.readonly"] = { link = "@constant" },
				}
			end,
		})

		vim.cmd.colorscheme("monokai-pro")
	end,
}
