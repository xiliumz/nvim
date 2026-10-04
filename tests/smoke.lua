-- Runs only against the temporary HOME/XDG directories created by run.sh.
local root = vim.fn.stdpath("config")
vim.opt.rtp:prepend(root)
local errors, expected, configured = {}, {}, {}
local notify = vim.notify
vim.notify = function(message, level, opts)
	if level == vim.log.levels.ERROR then
		table.insert(errors, tostring(message))
	end
	return notify(message, level, opts)
end

for _, path in ipairs(vim.fn.globpath(root .. "/lua/features", "*.lua", false, true)) do
	local name = vim.fn.fnamemodify(path, ":t:r")
	local feature = require("features." .. name)
	for _, plugin in ipairs(feature.plugins) do
		if plugin ~= "telescope-fzf-native.nvim" or vim.fn.executable("make") == 1 then
			expected[plugin] = true
		end
	end
	configured[name] = 0
	local setup = feature.setup
	feature.setup = function(...)
		assert(select("#", ...) == 0, "setup should not receive feature toggles")
		setup()
		configured[name] = configured[name] + 1
	end
end

-- Exercise real plugins without installing external language tools or starting
-- Supermaven's network client. No editor contents leave the test process.
local add = vim.pack.add
vim.pack.add = function(specs, opts)
	local seen = {}
	for _, spec in ipairs(specs) do
		assert(not seen[spec.name], "duplicate plugin: " .. spec.name)
		seen[spec.name] = true
	end
	add(specs, opts)
	local installer = require("mason-tool-installer")
	local setup = installer.setup
	installer.setup = function(options)
		options.run_on_start = false
		setup(options)
	end
	require("supermaven-nvim.api").start = function() end
end

local function check()
	assert(vim.v.errmsg == "", vim.v.errmsg)
	assert(#errors == 0, table.concat(errors, "\n"))
	assert(package.loaded.lazy == nil, "lazy.nvim must not be loaded")
	assert(vim.fn.filereadable(root .. "/lua/features.lua") == 0, "obsolete toggle file")
	for name, count in pairs(configured) do
		assert(count == 1, name .. " must be configured exactly once")
	end
	for _, plugin in ipairs(vim.pack.get(nil, { info = false })) do
		assert(plugin.active == (expected[plugin.spec.name] == true), plugin.spec.name .. " active state")
		if plugin.active then
			expected[plugin.spec.name] = nil
			local rev = vim.system({ "git", "-C", plugin.path, "rev-parse", "HEAD" }, { text = true }):wait()
			assert(vim.trim(rev.stdout) == require("plugins")[plugin.spec.name].version, "revision drift")
		end
	end
	assert(next(expected) == nil, "missing active plugin")
	assert(vim.o.shiftwidth == 2 and vim.o.relativenumber, "core options")
	assert(vim.fn.maparg("d", "n") == '"_d', "core mapping")
	for _, key in ipairs({ "<leader>e", "<leader>gd", "<leader>f" }) do
		assert(vim.fn.maparg(key, "n") ~= "", "missing mapping: " .. key)
	end
	vim.api.nvim_exec_autocmds("LspAttach", { buffer = 0, data = { client_id = -1 } })
	assert(vim.fn.maparg("grd", "n", false, true).callback == require("telescope.builtin").lsp_definitions)
	assert(require("context.config").options.picker == require("context.pickers").telescope)
	assert(require("telescope").extensions.frecency.frecency, "frecency extension")
	if vim.fn.executable("make") == 1 then
		assert(pcall(require, "fzf_lib"), "native fzf build")
	end
	if vim.env.NVIM_TEST_SCENARIO == "discovery" then
		assert(vim.g.discovery_probe == 1, "new module was not automatically loaded")
	end

	-- Saving must format immediately, without invoking <leader>f first.
	local conform = require("conform")
	conform.formatters_by_ft.moduletest = { "uppercase_test" }
	conform.formatters.uppercase_test = { command = "tr", args = { "a-z", "A-Z" }, stdin = true }
	vim.api.nvim_buf_set_name(0, vim.fn.getcwd() .. "/format-check")
	vim.bo.filetype = "moduletest"
	vim.api.nvim_buf_set_lines(0, 0, -1, false, { "format me" })
	vim.cmd("silent write!")
	assert(vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] == "FORMAT ME", "format on first save")
	assert(vim.fn.readfile(vim.api.nvim_buf_get_name(0))[1] == "FORMAT ME", "formatted text saved")
	assert(#errors == 0, table.concat(errors, "\n"))
	print("PASS " .. vim.env.NVIM_TEST_SCENARIO)
end

local ok, err = xpcall(function()
	dofile(root .. "/init.lua")
end, debug.traceback)
if not ok then
	io.stderr:write(err .. "\n")
	vim.cmd("cquit 1")
end
vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		vim.defer_fn(function()
			local success, failure = xpcall(check, debug.traceback)
			if not success then
				io.stderr:write(failure .. "\n")
				vim.cmd("cquit 1")
			end
			vim.cmd("qa!")
		end, 200)
	end,
})
