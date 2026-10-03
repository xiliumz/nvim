return {
	plugins = { "nvim-treesitter", "nvim-treesitter-context", "nvim-ts-autotag" },
	setup = function()
		local treesitter = require("nvim-treesitter")

		local available = {}
		for _, lang in ipairs(treesitter.get_available()) do
			available[lang] = true
		end

		vim.api.nvim_create_autocmd("FileType", {
			callback = function(event)
				local buf = event.buf
				local ft = vim.bo[buf].filetype
				local lang = vim.treesitter.language.get_lang(ft)

				if not lang or not available[lang] then
					return
				end

				local function start()
					if not vim.api.nvim_buf_is_valid(buf) then
						return
					end

					pcall(vim.treesitter.start, buf, lang)

					vim.wo.foldmethod = "expr"
					vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
					vim.wo.foldlevel = 99
					vim.wo.foldenable = true

					if ft ~= "ruby" then
						vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end

				local parser = vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false)

				if #parser == 0 then
					treesitter.install({ lang }):await(start)
				else
					start()
				end
			end,
		})
		require("treesitter-context").setup({})
		vim.keymap.set("n", "<leader>[", function()
			require("treesitter-context").go_to_context(vim.v.count1)
		end, { desc = "Go to parent context" })
		require("nvim-ts-autotag").setup({})
	end,
}
