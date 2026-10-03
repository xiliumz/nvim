return {
	plugins = { "conform.nvim", "mason.nvim", "mason-tool-installer.nvim" },
	tools = { "stylua", "eslint_d", "prettierd", "sleek" },
	setup = function()
		require("conform").setup({
			format_on_save = {
				timeout_ms = 500,
				lsp_format = "fallback",
			},
			default_format_opts = {
				stop_after_first = true,
			},
			formatters_by_ft = {
				lua = { "stylua" },
				nix = { "nixfmt" },
				javascript = {
					"prettierd",
					"eslint_d",
				},
				typescript = {
					"eslint_d",
				},
				javascriptreact = {
					"prettierd",
					"eslint_d",
				},
				typescriptreact = {
					"eslint_d",
				},
				json = { "prettierd" },
				css = { "prettierd" },
				markdown = { "prettierd" },
				sql = { "sleek" },
			},
		})
		vim.keymap.set("", "<leader>f", function()
			require("conform").format({ async = true, lsp_format = "fallback" })
		end, { desc = "[F]ormat buffer" })
	end,
}
