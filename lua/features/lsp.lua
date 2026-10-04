return {
	plugins = {
		"nvim-lspconfig",
		"mason.nvim",
		"mason-lspconfig.nvim",
		"mason-tool-installer.nvim",
		"fidget.nvim",
		"lazydev.nvim",
	},
	tools = { "astro", "yamlls", "lua_ls", "ts_ls", "cssmodules_ls", "tailwindcss", "pyright" },
	setup = function()
		require("lazydev").setup({
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		})
		require("fidget").setup({})
		local builtin = require("telescope.builtin")
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
			callback = function(event)
				local map = function(keys, func, desc, mode)
					mode = mode or "n"
					vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
				end

				map("grn", vim.lsp.buf.rename, "[R]e[n]ame")

				map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })

				map("grr", builtin.lsp_references, "[G]oto [R]eferences")

				map("gri", builtin.lsp_implementations, "[G]oto [I]mplementation")

				map("grd", builtin.lsp_definitions, "[G]oto [D]efinition")

				map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

				map("gO", builtin.lsp_document_symbols, "Open Document Symbols")

				map("gW", builtin.lsp_dynamic_workspace_symbols, "Open Workspace Symbols")

				map("grt", builtin.lsp_type_definitions, "[G]oto [T]ype Definition")

				map("<leader>F", vim.diagnostic.open_float, "[F]loat diagnostic")

				local client = vim.lsp.get_client_by_id(event.data.client_id)
				if
					client
					and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf)
				then
					local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
					vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
						buffer = event.buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.document_highlight,
					})

					vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
						buffer = event.buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.clear_references,
					})

					vim.api.nvim_create_autocmd("LspDetach", {
						group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
						callback = function(event2)
							vim.lsp.buf.clear_references()
							vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
						end,
					})
				end

				if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
					map("<leader>i", function()
						vim.lsp.inlay_hint.enable(
							not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }),
							{ bufnr = event.buf }
						)
					end, "[T]oggle [I]nlay [H]ints")
				end
			end,
		})

		vim.diagnostic.config({
			signs = vim.g.have_nerd_font and {
				text = {
					[vim.diagnostic.severity.ERROR] = "󰅚 ",
					[vim.diagnostic.severity.WARN] = "󰀪 ",
					[vim.diagnostic.severity.INFO] = "󰋽 ",
					[vim.diagnostic.severity.HINT] = "󰌶 ",
				},
			} or {},
			virtual_text = {
				source = "if_many",
				spacing = 2,
				format = function(diagnostic)
					local diagnostic_message = {
						[vim.diagnostic.severity.ERROR] = diagnostic.message,
						[vim.diagnostic.severity.WARN] = diagnostic.message,
						[vim.diagnostic.severity.INFO] = diagnostic.message,
						[vim.diagnostic.severity.HINT] = diagnostic.message,
					}
					return diagnostic_message[diagnostic.severity]
				end,
			},
		})

		local capabilities = require("blink.cmp").get_lsp_capabilities()
		vim.lsp.config("*", { capabilities = capabilities })
		require("mason-lspconfig").setup({
			automatic_enable = {
				exclude = { "cssmodules_ls", "tailwindcss", "yamlls" },
			},
		})
	end,
}
