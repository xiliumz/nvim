return {
	plugins = {
		"plenary.nvim",
		"nvim-web-devicons",
		"telescope.nvim",
		"telescope-ui-select.nvim",
		"telescope-frecency.nvim",
		"telescope-fzf-native.nvim",
	},
	setup = function()
		require("telescope").setup({
			pickers = {
				find_files = {
					hidden = true,
					find_command = { "rg", "--files", "--hidden", "--glob", "!.git/*" },
					path_display = { "filename_first" },
				},
			},
			extensions = {
				["ui-select"] = {
					require("telescope.themes").get_dropdown(),
				},
				frecency = {
					auto_validate = true,
					db_validate_threshold = 1,
					matcher = "fuzzy",
					path_display = { "filename_first" },
				},
			},
		})

		pcall(require("telescope").load_extension, "fzf")
		pcall(require("telescope").load_extension, "ui-select")
		pcall(require("telescope").load_extension, "frecency")

		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
		vim.keymap.set("n", "<leader>sc", builtin.commands, { desc = "[S]earch [C]ommands" })
		vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
		vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
		vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
		vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
		vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
		vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
		vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
		vim.keymap.set("n", "<leader>s.", function()
			require("telescope").extensions.frecency.frecency({
				workspace = "CWD",
			})
		end, { desc = '[S]earch Recent Files ("." for repeat)' })
		vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

		vim.keymap.set("n", "<leader>gf", builtin.git_status, { desc = "Search [G]it Changed [F]iles" })
		vim.keymap.set("n", "<leader>gs", function()
			builtin.git_files({
				git_command = { "git", "-c", "core.quotepath=false", "diff", "--cached", "--name-only" },
				prompt_title = "Staged Files",
			})
		end, { desc = "Search [G]it [S]taged files" })
		vim.keymap.set("n", "<leader>gu", function()
			builtin.git_files({
				git_command = {
					"git",
					"-c",
					"core.quotepath=false",
					"ls-files",
					"--modified",
					"--others",
					"--exclude-standard",
				},
				prompt_title = "Unstaged Files",
				attach_mappings = function(_, map)
					map({ "i", "n" }, "<Tab>", function(prompt_bufnr)
						local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
						picker:delete_selection(function(entry)
							local output = vim.fn.system({
								"git",
								"-C",
								picker.cwd or vim.fn.getcwd(),
								"add",
								"--",
								entry.value,
							})
							if vim.v.shell_error ~= 0 then
								vim.notify(output, vim.log.levels.ERROR)
								return false
							end
						end)
					end)
					return true
				end,
			})
		end, { desc = "Search [G]it [U]nstaged files" })

		vim.keymap.set("n", "<leader>/", function()
			builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
				winblend = 10,
				previewer = false,
				layout_config = {
					width = 0.8,
					height = 0.6,
				},
			}))
		end, { desc = "[/] Fuzzily search in current buffer" })

		vim.keymap.set("n", "<leader>s/", function()
			builtin.live_grep({
				grep_open_files = true,
				prompt_title = "Live Grep in Open Files",
			})
		end, { desc = "[S]earch [/] in Open Files" })

		vim.keymap.set("n", "<leader>sn", function()
			builtin.find_files({ cwd = vim.fn.stdpath("config") })
		end, { desc = "[S]earch [N]eovim files" })
	end,
}
