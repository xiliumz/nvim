-- [[ Vim Global Options ]]
vim.g.mapleader = " "
vim.g.mapLocalLeader = " "
-- [[ Vim Options ]]
-- Show line number
vim.o.number = true -- What's the difference between opt.number and o.number?

vim.o.showmode= false

vim.o.cursorline = true

vim.o.scrolloff = 15

vim.o.breakindent = true

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.signcolumn = 'yes'

vim.o.timeoutlen = 300

vim.o.updatetime = 200

vim.o.confirm = true

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

-- Manual user Setup
vim.keymap.set('n', '<C-E>', ':Neotree filesystem reveal left<CR>')
vim.keymap.set('n', '<C-s>', ':w<CR>')
vim.keymap.set('n', '<C-n>', ':nohlsearch<CR>')

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- 🌈 Monokai Pro colorscheme
    {
      "loctvl842/monokai-pro.nvim",
      name = "monokai-pro",
      priority = 1000, -- load first
      config = function()
        require("monokai-pro").setup({
          filter = "pro", -- "classic", "octagon", "pro", "machine", "ristretto", "spectrum"
        })
        vim.cmd.colorscheme("monokai-pro")
      end,
    },
    -- Telescope -> Fuzzy finder
    {
      'nvim-telescope/telescope.nvim',
      tag = '0.1.8',
      dependencies = { 'nvim-lua/plenary.nvim' },
      config = function()
        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<C-p>', builtin.find_files, { desc = 'Telescope find files' })
        vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
      end,
    },
    -- Tree Sitter -> Highlighting and Indenting
    {
      "nvim-treesitter/nvim-treesitter",
      branch = 'master',
      lazy = false,
      build = ":TSUpdate",
      config = function()
        require('nvim-treesitter.configs').setup({
          -- A list of parser names, or "all" (the listed parsers MUST always be installed)
          auto_installed = true,
          highlight = { enable = true },
          indent = { enable = true },
        })
      end,
    },
    -- Neotree -> File explorer
    {
      "nvim-neo-tree/neo-tree.nvim",
      branch = "v3.x",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-tree/nvim-web-devicons", -- optional, but recommended
      },
      config = function()
        require('neo-tree').setup({
          filesystem = {
            filtered_items = {
              visible = true, -- Show hidden files
              hide_dotfiles = false,
            }
          }
        })
      end,
      lazy = false, -- neo-tree will lazily load itself
    },
    -- Lualine -> Bottom status line
    {
      'nvim-lualine/lualine.nvim',
      dependencies = { 'nvim-tree/nvim-web-devicons' },
      config = function()
        require('lualine').setup({
          options = { theme = 'dracula' }
        })
      end,
    },
    -- Mason -> manage external editor tooling such as LSP servers, DAP servers, linters, and formatters through a single interface.
    {
      "mason-org/mason.nvim",
      opts = {},
    },
    {
      "mason-org/mason-lspconfig.nvim",
      config = function()
        require("mason-lspconfig").setup({
          ensure_installed = { "lua_ls", "ts_ls" },
          automatic_enable = true
        })
      end,
    },
    {
      "neovim/nvim-lspconfig",
      config = function()
        local lspconfig = require("lspconfig")
        lspconfig.lua_ls.setup({})
        lspconfig.ts_ls.setup({
          -- on_attach = function(client, bufnr)
          --   if client.server_capabilities.semanticTokensProvider then
          --     vim.lsp.semantic_tokens.start(bufnr, client.id)
          --   end
          -- end
        })
        vim.keymap.set('n', '<leader>gf', vim.lsp.buf.format)
      end,
    },
    -- none-ls -> Code formating and linting
    {
      "nvimtools/none-ls.nvim",
      config = function()
        local null_ls = require("null-ls")
        null_ls.setup({
          sources = {
            null_ls.builtins.formatting.stylua,
            null_ls.builtins.completion.spell,
          },
        })
      end,
    },
    -- Additional `lazy` setup
    install = { colorscheme = { "habamax" } },
    checker = { enabled = true },
  },
})
