-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- LSP configuration — Neovim 0.12 native approach
-- No nvim-lspconfig needed! Uses vim.lsp.config + vim.lsp.enable
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- LspAttach autocommand for buffer-local setup
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("LspSetup", { clear = true }),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then
            return
        end

        local buf = args.buf

        -- Enable inlay hints if supported
        if client:supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable(true, { bufnr = buf })
        end

        -- Code lens is deliberately not enabled — too noisy inline.
        -- Run one on demand with vim.lsp.codelens.run() if ever needed.

        -- Enable document highlight on cursor hold
        if client:supports_method("textDocument/documentHighlight") then
            local hl_group = vim.api.nvim_create_augroup("LspHighlight_" .. buf, { clear = true })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                group = hl_group,
                buffer = buf,
                callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                group = hl_group,
                buffer = buf,
                callback = vim.lsp.buf.clear_references,
            })
        end

        -- Buffer-local keymaps (supplement defaults: gra/grr/grn/grt/grx/gO)
        local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = "LSP: " .. desc })
        end

        map("n", "<leader>ih", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
        end, "Toggle inlay hints")
    end,
})

-- Enable all configured LSP servers.
-- Server configs live in after/lsp/<name>.lua and are picked up from the
-- runtimepath automatically — 'after' so they win over anything a plugin ships.
vim.lsp.enable({
    "lua_ls", -- Lua
    "vtsls", -- TypeScript/JavaScript
    "eslint", -- JS/TS linting
    "gopls", -- Go
    "rust_analyzer", -- Rust
    "zls", -- Zig
    "basedpyright", -- Python (types)
    "ruff", -- Python (lint/format)
    "clangd", -- C/C++
    "cssls", -- CSS
    "html", -- HTML
    "jsonls", -- JSON (package.json/tsconfig 等)
    "yamlls", -- YAML
    "buf_ls", -- Protobuf (buf)
    "protols", -- Protobuf
    "typos_lsp", -- Spell checking
})
