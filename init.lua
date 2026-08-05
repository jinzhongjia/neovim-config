-- ╔══════════════════════════════════════════════════════════════╗
-- ║  Neovim 0.12 Minimal Performance Config                     ║
-- ║  LSP + DAP | TS Go Rust Python C CSS HTML                   ║
-- ║  Principle: Built-in first, minimal plugins, max speed      ║
-- ╚══════════════════════════════════════════════════════════════╝

-- Core settings (no plugins needed)
require("core.options")
require("core.keymaps")
require("core.autocmds")
require("core.diagnostics")
require("core.lsp")

-- Plugin management (vim.pack built-in)
require("plugins")
