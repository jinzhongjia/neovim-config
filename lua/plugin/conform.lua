local status, conform = pcall(require, "conform")
if not status then
    vim.notify("not found conform")
    return
end

conform.setup({
    formatters_by_ft = {
        c = { "clang_format" },
        go = {
            "gofumpt",
            "goimports",
        },
        html = { "prettierd" },
        json = { "prettierd" },
        jsonc = { "prettierd" },
        rust = { "rustfmt" },
        bash = { "shfmt" },
        lua = { "stylua" },
        -- Conform will use the first available formatter in the list
        javascript = { "prettierd" },
        typescript = { "prettierd" },
        javascriptreact = { "prettierd" },
        typescriptreact = { "prettierd" },
        vue = { "prettierd" },
        -- Formatters can also be specified with additional options
        python = {
            "isort",
            "black",
        },
        zig = { "zigfmt" },
        markdown = {
            "prettierd",
            "markdownlint",
        },
    },
})
