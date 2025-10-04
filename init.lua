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
-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true
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
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search'})
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic'})
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode'})
-- Terminal Horizontal split
vim.keymap.set('n', '<leader>th', '<cmd>belowright split | terminal<CR>', { desc = 'Split terminal horizontally (open bottom)'})
-- Terminal Vertical split
vim.keymap.set('n', '<leader>tv', '<cmd>belowright vsplit | terminal<CR>', { desc = 'Split terminal horizontally (open right)'})

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

-- Example of vim.ui.select()
-- vim.keymap.set("n", "<leader>cc", function()
--   local colors = { "red", "green", "blue", "yellow" }
--   vim.ui.select(colors, { prompt = "Choose a color:" }, function(choice)
--     if choice then
--       vim.api.nvim_set_hl(0, "Normal", { fg = choice })
--       print("Color changed to " .. choice)
--     end
--   end)
-- end, { desc = "Choose highlight color" })

--
-- [[ Configure and install plugins ]]
-- Setup lazy.nvim
require("lazy").setup({
	{
  'NMAC427/guess-indent.nvim', -- Detect tabstop and shiftwidth automatically
  config = function()
	  require('guess-indent').setup()
  end,
	},

  -- Themes
  -- {
  --   "catppuccin/nvim",
  --   name = "catppuccin",
  --   priority = 1000, 
  --   config = function()
  --     require("catppuccin").setup({
  --       transparent_background = true,
  --     })
  --     vim.cmd.colorscheme("catppuccin")
  --   end
  -- },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require('tokyonight').setup({
        transparent = true,
        terminal_colors = false,
      })
      vim.cmd.colorscheme("tokyonight-night")
    end,
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
  },

  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    opts = {
      -- delay between pressing a key and opening which-key (milliseconds)
      -- this setting is independent of vim.o.timeoutlen
      delay = 0,
      icons = {
        -- set icon mappings to true if you have a Nerd Font
        mappings = vim.g.have_nerd_font,
      },

      -- Document existing key chains
      spec = {
        { '<leader>s', group = '[S]earch' },
        -- { '<leader>t', group = '[T]erminal' },
        -- { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      },
    },
  },

	{
		'nvim-telescope/telescope.nvim',
		event = 'VimEnter',
		dependencies = {
			'nvim-lua/plenary.nvim',
			{
				'nvim-telescope/telescope-fzf-native.nvim',
				build = 'make',
				cond = function()
					return vim.fn.executable 'make' == 1
				end,
			},
			{ 'nvim-telescope/telescope-ui-select.nvim' },
			{ 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font }
		},
    config = function()
      require('telescope').setup {
       extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        }
      }

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

            -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(
          -- require('telescope.themes').get_dropdown {
          --   winblend = 20,
          --   previewer = false,
          -- }
        )
      end, { desc = '[/] Fuzzily search in current buffer' })

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
	}
})
