-- [[ Vim Global Options ]]
vim.g.mapleader = " "
vim.g.mapLocalLeader = " "

-- [[ Vim Options ]]
-- Tab Options
-- vim.opt.expandtab = true
-- vim.opt.tabstop = 2
-- vim.opt.shiftwidth = 2
-- Combine clipboard with system
vim.o.clipboard = 'unnamedplus'
-- Show line number
vim.o.number = true
vim.o.showmode = false
-- Highlight line under the cursor
vim.o.cursorline = true
-- Line scroll offset
vim.o.scrolloff = 20
-- Basically it will indent new line because of wrap line
vim.o.breakindent = true
-- Better for searching using `/`
vim.o.ignorecase = true
vim.o.smartcase = true
-- Add space next to line number for indicator
vim.o.signcolumn = 'yes'
-- Timeout for pressing command, eg: <leader>gf -> this will clear the typed command if not finished under 300ms
vim.o.timeoutlen = 500
-- How often vim update (re-run "CursorHold" event)
vim.o.updatetime = 200
-- Ask confirmation if something changed and not saved yet
vim.o.confirm = true

-- [[ Basic Keymaps ]]
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', {desc = 'Open diagnostic'})
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', {desc = 'Exit terminal mode'})
-- Terminal Horizontal split
vim.keymap.set('n', '<leader>th', '<cmd>belowright split | terminal<CR>')
-- Terminal Vertical split
vim.keymap.set('n', '<leader>tv', '<cmd>belowright vsplit | terminal<CR>')

-- [[ Basic Autocommands ]]
-- Highlight when yanking text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', {clear = true}),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
-- Setup lazy.nvim
require("lazy").setup({
  'NMAC427/guess-indent.nvim', -- Detect tabstop and shiftwidth automatically
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000, 
    config = function()
      require("catppuccin").setup({
        transparent_background = true,
      })
      vim.cmd.colorscheme("catppuccin")
    end
  },
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '-' },
        changedelete = { text = '~' }
      }
    }
  }
})
