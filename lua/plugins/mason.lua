-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Mason — LSP/DAP/Linter/Formatter package manager
-- Provides :MasonInstallAll to install everything in one shot
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

require("mason").setup({
    ui = {
        border = "rounded",
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
        },
    },
    -- Performance: limit concurrent installers
    max_concurrent_installers = 4,
})

-- All packages we need for LSP + DAP
local ensure_installed = {
    -- LSP servers (must match the vim.lsp.enable list in lua/core/lsp.lua)
    "lua-language-server", -- Lua
    "vtsls", -- TypeScript/JavaScript
    "eslint-lsp", -- JS/TS linting
    "gopls", -- Go
    "rust-analyzer", -- Rust
    "zls", -- Zig
    "basedpyright", -- Python (types)
    "ruff", -- Python (lint/format)
    "clangd", -- C/C++
    "dockerfile-language-server", -- Dockerfile (dockerls)
    "css-lsp", -- CSS
    "html-lsp", -- HTML
    "json-lsp", -- JSON
    "yaml-language-server", -- YAML
    "buf", -- Protobuf (buf_ls)
    "protols", -- Protobuf
    "typos-lsp", -- Spell checking

    -- DAP adapters
    "delve", -- Go debugger
    "codelldb", -- Rust/C debugger
    "debugpy", -- Python debugger
    "js-debug-adapter", -- JS/TS debugger

    -- Formatters (与 plugins/format.lua 的 conform 配置对应)
    "prettierd", -- HTML/CSS/JS/TS/JSON/MD formatter (daemon)
    "gofumpt", -- Go formatter
    "goimports", -- Go imports
    "stylua", -- Lua formatter
    "shfmt", -- Shell formatter
    "yamlfmt", -- YAML formatter
    "sleek", -- SQL formatter
    "clang-format", -- C/C++ formatter
}

-- :MasonInstallAll — one command to install everything
vim.api.nvim_create_user_command("MasonInstallAll", function()
    local registry = require("mason-registry")

    -- Ensure registry is up to date
    registry.refresh(function()
        local installed = 0
        local total = #ensure_installed

        for _, name in ipairs(ensure_installed) do
            local ok, pkg = pcall(registry.get_package, name)
            if ok then
                if not pkg:is_installed() then
                    vim.notify(string.format("[Mason] Installing %s...", name), vim.log.levels.INFO)
                    pkg:install()
                    installed = installed + 1
                end
            else
                vim.notify(string.format("[Mason] Package not found: %s", name), vim.log.levels.WARN)
            end
        end

        if installed == 0 then
            vim.notify("[Mason] All packages already installed!", vim.log.levels.INFO)
        else
            vim.notify(string.format("[Mason] Installing %d/%d packages...", installed, total), vim.log.levels.INFO)
        end
    end)
end, { desc = "Install all configured Mason packages" })

-- :MasonUpdateAll — update all installed packages
vim.api.nvim_create_user_command("MasonUpdateAll", function()
    local registry = require("mason-registry")
    registry.refresh(function()
        for _, pkg in ipairs(registry.get_installed_packages()) do
            pkg:install() -- reinstall = update
        end
        vim.notify("[Mason] Updating all installed packages...", vim.log.levels.INFO)
    end)
end, { desc = "Update all installed Mason packages" })

-- :MasonStatus — show what's installed vs what's needed
vim.api.nvim_create_user_command("MasonStatus", function()
    local registry = require("mason-registry")
    local lines = {
        "Mason Package Status:",
        "─────────────────────────────────",
    }

    for _, name in ipairs(ensure_installed) do
        local ok, pkg = pcall(registry.get_package, name)
        if ok then
            local status = pkg:is_installed() and "✓ installed" or "✗ missing"
            table.insert(lines, string.format("  %s  %s", status, name))
        else
            table.insert(lines, string.format("  ? unknown   %s", name))
        end
    end

    vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end, { desc = "Show Mason package installation status" })
