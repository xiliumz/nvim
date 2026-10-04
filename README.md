# Neovim configuration

Requires **Neovim 0.12+** and Git. Plugins are managed by the built-in `vim.pack`.

## Feature modules

Every `.lua` file directly under `lua/features/` is automatically discovered and
configured at startup. There is no toggle table or module registration list.
Add a module file and restart Neovim to load it:

```lua
return {
  plugins = {}, -- Plugin names from lua/plugins.lua.
  -- tools = {}, -- Optional Mason tools.
  setup = function()
    -- Configure the feature here.
  end,
}
```

`init.lua` collects and deduplicates plugin dependencies before loading them with
`vim.pack.add`. Mason is initialized before module setup. Theme, search, and
completion are configured first so their integrations are ready; remaining
modules run alphabetically. New plugins need a pinned entry in `lua/plugins.lua`.

| Module | Feature |
| --- | --- |
| `editing` | Indent detection, smooth scrolling, text objects, surround, TODO comments |
| `treesitter` | Syntax highlighting, folding, indentation, context, HTML autotags |
| `theme` | Monokai Pro spectrum, transparency, custom diff highlights |
| `buffers` | Bufferline and buffer navigation keybindings |
| `statusline` | Mini statusline |
| `which_key` | Keybinding hints |
| `explorer` | Fyler (`<leader>e`) |
| `search` | Telescope, native fzf, frecency, UI select, Git file pickers |
| `sessions` | Automatic session save/restore |
| `git` | Gitsigns, CodeDiff (`<leader>gd`), LazyGit (`<leader>lg`) |
| `lsp` | Language servers, diagnostics, Lua development support, progress |
| `completion` | Blink completion and signature help |
| `formatting` | Conform, formatter installation, format-on-save, `<leader>f` |
| `eslint` | Project ESLint integration through nvim-eslint |
| `supermaven` | AI inline completion |
| `ai_context` | Context picker (`<leader>a`) |
| `images` | Image rendering with the ImageMagick CLI processor |

Core options, clipboard handling, general keybindings, and yank highlighting in
`lua/core.lua` are always enabled. The leader remains Neovim's default (`\`).

LSP navigation and the AI context picker use Telescope; LSP capabilities use
Blink. LSP and formatting share Mason. Editing and statusline share mini.nvim.
Modules organize the configuration; they are not independently switchable.

The `eslint` module configures nvim-eslint, separate from Conform's `eslint_d`
formatter. Git file pickers belong to `search`, while Git signs, diff views,
and LazyGit belong to `git`.

## Startup and formatting

All modules are configured at startup; there is no replacement lazy-loading
framework. **Format-on-save is active immediately**, without first pressing
`<leader>f` or running `:ConformInfo`. This is the intentional behavior change
from the previous configuration. Formatting still uses a 500 ms timeout with
LSP fallback and the existing per-filetype formatter choices.

LSP uses `vim.lsp.config` and Mason's native enable integration. The existing
servers and automatic-enable exclusions (`cssmodules_ls`, `tailwindcss`,
`yamlls`) are preserved. Mason installs missing language tools as before;
the plugin revision pins do not pin those external tools.

## Installation and dependencies

On first startup, `vim.pack.add` downloads missing plugins automatically. Plugins
live under `stdpath('data')/site/pack/core/opt`, separate from the old `lazy/`
directory. Existing lazy.nvim installations and sessions are not deleted.

External tools remain the same as before:

- Telescope file search uses `rg`; its native fzf extension builds with `make`
  and a C compiler. Without `make`, the native extension is skipped.
- Treesitter installs parsers on demand and needs `tree-sitter` CLI 0.26.1+,
  a C compiler, `tar`, and `curl`.
- LazyGit needs the `lazygit` executable. Image rendering needs ImageMagick
  (`magick`, or `convert` and `identify`) and a compatible terminal.
- The existing clipboard fallback uses `xclip`; Supermaven manages its own
  agent download and authentication.

Plugin install/update hooks rebuild native fzf. Updating Treesitter updates its
installed parsers. CodeDiff manages its native library download on first use.

## Plugin versions and future updates

`lua/plugins.lua` pins all 33 retained plugins to the former `lazy-lock.json`
commit hashes. Only lazy.nvim itself was removed. `nvim-pack-lock.json` is
managed by Neovim; do not edit it manually.

`:lua vim.pack.update()` will not upgrade plugins while these commit pins remain.
To deliberately update a plugin later:

1. Change its `version` in `lua/plugins.lua` to a chosen commit, tag, or branch.
2. Restart Neovim and run `:lua vim.pack.update({ 'plugin-name' })`.
3. Review the update buffer; use `:write` to accept or `:quit` to discard.
4. Restart and commit both the pin change and native lockfile change.

Changing a pin alone does not change an already-installed checkout; the update
step is required. To synchronize an existing installation to a checked-in
lockfile, run `:lua vim.pack.update(nil, { target = 'lockfile' })` and review.

## Validation

```sh
bash tests/run.sh
```

Checks startup and automatic discovery of a newly added test module without
editing `init.lua`. Verifies each module runs once, shared plugins are deduplicated,
pinned checkouts, keybindings, Telescope integrations, native fzf, and formatting
on the first save.

The runner creates an isolated temporary HOME and XDG directories, downloads
plugins, and builds native fzf. It does not modify normal Neovim data or sessions.
Logs and test downloads are retained at the printed temporary path. External
Mason tool installation and Supermaven's network client are suppressed in tests;
interactive rendering, real language servers, and AI responses are not tested.

`clean_nvim.sh` is unchanged: it deletes **all** normal Neovim data, state, and
cache, including sessions and installed tools. It is not required for migration
and does not remove the native lockfile from the configuration directory.
