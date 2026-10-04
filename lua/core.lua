vim.g.have_nerd_font = true

vim.opt.wrap = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.o.autoread = true
local original_user = vim.fn.system("logname"):gsub("%s+", "")
local current_user = os.getenv("USER")

if original_user ~= current_user then
	vim.g.clipboard = {
		name = "OSC 52 + xclip Paste",
		copy = {
			["+"] = require("vim.ui.clipboard.osc52").copy("+"),
			["*"] = require("vim.ui.clipboard.osc52").copy("*"),
		},
		paste = {
			["+"] = { "xclip", "-selection", "clipboard", "-o" },
			["*"] = { "xclip", "-selection", "primary", "-o" },
		},
	}
end
vim.o.clipboard = "unnamedplus"
vim.o.number = true
vim.o.relativenumber = true
vim.o.showmode = false
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.cursorline = true
vim.o.scrolloff = 15
vim.o.breakindent = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = "yes"
vim.o.timeoutlen = 500
vim.o.updatetime = 200
vim.o.confirm = true
vim.o.list = true
vim.opt.listchars = {
	tab = "_ ",
	trail = "·",
	nbsp = "␣",
}

vim.keymap.set({ "n", "v" }, "d", '"_d')
vim.keymap.set({ "n", "v" }, "D", '"_D')
vim.keymap.set({ "n", "v" }, "x", '"_x')
vim.keymap.set({ "n", "v" }, "c", '"_c')
vim.keymap.set({ "n", "v" }, "C", '"_C')

vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", {}) -- Alt j to down
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", {}) -- Alt k to up
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<A-Down>", ":m .+1<CR>==", {})
vim.keymap.set("n", "<A-Up>", ":m .-2<CR>==", {})
vim.keymap.set("v", "<A-Down>", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "<A-Up>", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic" })
vim.keymap.set(
	"n",
	"<leader>th",
	"<cmd>belowright split | terminal<CR>",
	{ desc = "Split terminal horizontally (open bottom)" }
)
vim.keymap.set(
	"n",
	"<leader>tv",
	"<cmd>belowright vsplit | terminal<CR>",
	{ desc = "Split terminal horizontally (open right)" }
)

vim.keymap.set({ "n", "v" }, "<C-Up>", "3k", { desc = "Move up 3 lines" })
vim.keymap.set({ "n", "v" }, "<C-Down>", "3j", { desc = "Move down 3 lines" })

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})
