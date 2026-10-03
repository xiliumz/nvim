return {
	plugins = { "plenary.nvim", "gitsigns.nvim", "codediff.nvim", "lazygit.nvim" },
	setup = function()
		require("gitsigns").setup({
			current_line_blame = true,
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
			on_attach = function(bufnr)
				local gitsigns = require("gitsigns")

				local function map(mode, l, r, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
				end

				map("n", "]c", function()
					if vim.wo.diff then
						vim.cmd.normal({ "]c", bang = true })
					else
						gitsigns.nav_hunk("next")
					end
				end, { desc = "Next [C]hange" })

				map("n", "[c", function()
					if vim.wo.diff then
						vim.cmd.normal({ "[c", bang = true })
					else
						gitsigns.nav_hunk("prev")
					end
				end, { desc = "Previous [C]hange" })

				map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "[H]unk [S]tage" })
				map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "[H]unk [R]eset" })

				map("v", "<leader>hs", function()
					gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, { desc = "[H]unk [S]tage (Visual)" })

				map("v", "<leader>hr", function()
					gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, { desc = "[H]unk [R]eset (Visual)" })

				map("n", "<leader>hS", gitsigns.stage_buffer, { desc = "[H]unk [S]tage Buffer" })
				map("n", "<leader>hR", gitsigns.reset_buffer, { desc = "[H]unk [R]eset Buffer" })

				map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "[H]unk [P]review" })
				map("n", "<leader>hi", gitsigns.preview_hunk_inline, { desc = "[H]unk Preview [I]nline" })

				map("n", "<leader>hb", function()
					gitsigns.blame_line({ full = true })
				end, { desc = "[H]unk [B]lame line" })

				map("n", "<leader>hd", gitsigns.diffthis, { desc = "[H]unk [D]iff file" })
				map("n", "<leader>hD", function()
					gitsigns.diffthis("~")
				end, { desc = "[H]unk [D]iff last commit" })

				map("n", "<leader>hQ", function()
					gitsigns.setqflist("all")
				end, { desc = "[H]unks to Quickfix (all)" })
				map("n", "<leader>hq", gitsigns.setqflist, { desc = "[H]unks to Quickfix" })

				map("n", "<leader>tb", gitsigns.toggle_current_line_blame, { desc = "[T]oggle [B]lame line" })
				map("n", "<leader>tw", gitsigns.toggle_word_diff, { desc = "[T]oggle [W]ord diff" })

				map({ "o", "x" }, "ih", gitsigns.select_hunk, { desc = "Select [H]unk (text object)" })
			end,
		})
		require("codediff").setup({
			diff = {
				layout = "inline",
			},
			explorer = {
				hidden = true,
				view_mode = "tree", -- "list" or "tree"
				focus_on_select = true,
			},
		})
		vim.keymap.set("n", "<leader>gd", "<cmd>CodeDiff<cr>", { desc = "Toggle Code Diff" })
		vim.keymap.set("n", "<leader>lg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })
	end,
}
