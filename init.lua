-- ╔══════════════════════════════════════════════════════════════╗
-- ║  Neovim 0.12 Minimal Performance Config                     ║
-- ║  LSP + DAP | TS Go Rust Python C CSS HTML                   ║
-- ║  Principle: Built-in first, minimal plugins, max speed      ║
-- ╚══════════════════════════════════════════════════════════════╝

-- Lua 模块字节码缓存（0.12 仍非默认），必须在一切 require 之前
vim.loader.enable()

-- Core settings (no plugins needed)
require("core.options")
require("core.keymaps")
require("core.autocmds")
require("core.diagnostics")
require("core.lsp")

-- Plugin management (vim.pack built-in)
require("plugins")
