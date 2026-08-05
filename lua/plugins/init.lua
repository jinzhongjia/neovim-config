-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Plugin management via vim.pack (built-in, Neovim 0.12)
-- Minimal plugin set — only what built-in cannot do
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local gh = function(repo) return "https://github.com/" .. repo end

vim.pack.add({
  -- ┌─────────────────────────────────────────────────────────┐
  -- │ Treesitter — syntax highlighting & textobjects          │
  -- │ (built-in TS exists but nvim-treesitter manages parsers)│
  -- └─────────────────────────────────────────────────────────┘
  { src = gh("nvim-treesitter/nvim-treesitter"), version = "main" },

  -- ┌─────────────────────────────────────────────────────────┐
  -- │ Fuzzy Finder — fzf-lua (fastest picker, no dependencies)│
  -- └─────────────────────────────────────────────────────────┘
  gh("ibhagwan/fzf-lua"),

  -- ┌─────────────────────────────────────────────────────────┐
  -- │ File Tree — nvim-tree (sidebar tree, replaces netrw)    │
  -- └─────────────────────────────────────────────────────────┘
  gh("nvim-tree/nvim-tree.lua"),
  gh("nvim-tree/nvim-web-devicons"),  -- icons for nvim-tree + bufferline

  -- ┌─────────────────────────────────────────────────────────┐
  -- │ Bufferline — buffer tabs                                │
  -- └─────────────────────────────────────────────────────────┘
  gh("akinsho/bufferline.nvim"),

  gh("echasnovski/mini.pairs"),

  -- ┌─────────────────────────────────────────────────────────┐
  -- │ Motion — flash.nvim (label jumps, treesitter select)    │
  -- └─────────────────────────────────────────────────────────┘
  gh("folke/flash.nvim"),

  -- ┌─────────────────────────────────────────────────────────┐
  -- │ Mason — LSP/DAP package manager                         │
  -- └─────────────────────────────────────────────────────────┘
  gh("williamboman/mason.nvim"),

  -- ┌─────────────────────────────────────────────────────────┐
  -- │ lspconfig — base lsp/<name>.lua (cmd/filetypes/roots).  │
  -- │ Our after/lsp/*.lua only carry settings overrides, so   │
  -- │ this supplies what they omit. No setup() call needed.   │
  -- └─────────────────────────────────────────────────────────┘
  gh("neovim/nvim-lspconfig"),

  -- ┌─────────────────────────────────────────────────────────┐
  -- │ lazydev — Neovim Lua types for lua_ls                   │
  -- └─────────────────────────────────────────────────────────┘
  gh("folke/lazydev.nvim"),

  -- ┌─────────────────────────────────────────────────────────┐
  -- │ DAP — Debug Adapter Protocol                            │
  -- └─────────────────────────────────────────────────────────┘
  gh("mfussenegger/nvim-dap"),
  gh("rcarriga/nvim-dap-ui"),
  gh("nvim-neotest/nvim-nio"),  -- required by dap-ui

  -- ┌─────────────────────────────────────────────────────────┐
  -- │ Git — Fugitive (classic, fast, zero-config)             │
  -- └─────────────────────────────────────────────────────────┘
  gh("tpope/vim-fugitive"),

  -- ┌─────────────────────────────────────────────────────────┐
  -- │ AI — Claude Code + OpenCode + Copilot                   │
  -- └─────────────────────────────────────────────────────────┘
  gh("coder/claudecode.nvim"),
  gh("sudo-tee/opencode.nvim"),
  gh("zbirenbaum/copilot.lua"),

  -- ┌─────────────────────────────────────────────────────────┐
  -- │ Colorscheme — vscode.nvim (no deps)                     │
  -- └─────────────────────────────────────────────────────────┘
  gh("Mofiqul/vscode.nvim"),
})

-- Load plugin configs after pack
require("plugins.mason")
require("plugins.lazydev")
require("plugins.treesitter")
require("plugins.fzf")
require("plugins.file-explorer")
require("plugins.flash")
require("plugins.dap")
require("plugins.colorscheme")
require("plugins.statusline")
require("plugins.bufferline")
require("plugins.ui2")
require("plugins.difftool")
require("plugins.git")
require("plugins.ai")
require("plugins.copilot")
require("plugins.terminal")
require("plugins.pairs")
