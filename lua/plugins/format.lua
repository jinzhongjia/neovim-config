-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- conform.nvim — 格式化编排（<leader>cf，见 core/keymaps.lua）
-- 配置移植自 main 分支；没配的语言 fallback 到 LSP 格式化
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

require("conform").setup({
    default_format_opts = {
        lsp_format = "fallback",
    },
    formatters_by_ft = {
        c = { "clang_format" },
        cpp = { "clang_format" },
        go = { "goimports", "gofumpt" },
        rust = { "rustfmt" },
        zig = { "zigfmt" },
        lua = { "stylua" },
        python = { "ruff_organize_imports", "ruff_format" },
        bash = { "shfmt" },
        sh = { "shfmt" },
        html = { "prettierd" },
        css = { "prettierd" },
        javascript = { "prettierd" },
        typescript = { "prettierd" },
        javascriptreact = { "prettierd" },
        typescriptreact = { "prettierd" },
        vue = { "prettierd" },
        json = { "prettierd" },
        jsonc = { "prettierd" },
        markdown = { "prettierd" },
        yaml = { "yamlfmt" },
        proto = { "buf" },
        sql = { "sleek" },
    },
})
