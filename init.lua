if vim.fn.has("nvim-0.12") == 0 then
	error("This configuration requires Neovim 0.12 or newer")
end

require("core")
local plugins = require("plugins")
local names = {}
for _, path in ipairs(vim.fn.globpath(vim.fn.stdpath("config") .. "/lua/features", "*.lua", false, true)) do
	table.insert(names, vim.fn.fnamemodify(path, ":t:r"))
end
-- Configure the theme and integrations before their consumers; everything else is alphabetical.
local priority = { theme = 1, search = 2, completion = 3 }
table.sort(names, function(a, b)
	local pa, pb = priority[a] or 4, priority[b] or 4
	return pa < pb or (pa == pb and a < b)
end)
local modules, specs, tools, added = {}, {}, {}, {}
for _, name in ipairs(names) do
	local feature = require("features." .. name)
	table.insert(modules, feature)
	for _, plugin in ipairs(feature.plugins) do
		local available = plugin ~= "telescope-fzf-native.nvim" or vim.fn.executable("make") == 1
		if available and not added[plugin] then
			table.insert(specs, vim.tbl_extend("force", plugins[plugin], { name = plugin }))
			added[plugin] = true
		end
	end
	vim.list_extend(tools, feature.tools or {})
end

vim.api.nvim_create_autocmd("PackChanged", {
	group = vim.api.nvim_create_augroup("config-pack-build", { clear = true }),
	callback = function(event)
		local data = event.data
		if data.kind == "delete" then
			return
		end
		if data.spec.name == "telescope-fzf-native.nvim" and vim.fn.executable("make") == 1 then
			local result = vim.system({ "make" }, { cwd = data.path, text = true }):wait()
			if result.code ~= 0 then
				error("telescope-fzf-native build failed: " .. (result.stderr or result.stdout or ""))
			end
		elseif data.spec.name == "nvim-treesitter" and data.kind == "update" then
			vim.cmd.packadd("nvim-treesitter")
			require("nvim-treesitter").update()
		end
	end,
})

if #specs > 0 then
	vim.pack.add(specs, { confirm = false })
end
if added["mason.nvim"] then
	require("mason").setup({})
end
for _, feature in ipairs(modules) do
	feature.setup()
end
if #tools > 0 then
	require("mason-tool-installer").setup({ ensure_installed = tools })
end
