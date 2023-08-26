local status, conform = pcall(require, "conform")
if not status then
    vim.notify("not found conform")
    return
end

conform.setup({
    formatters_by_ft = {
        c = { "clang_format" },
        go = {
            formatters = { "gofumpt", "goimports" },
            run_all_formatters = true,
        },
        html = { "prettier_d" },
        json = { "jq" },
        rust = { "rustfmt" },
        bash = { "shfmt" },
        lua = { "stylua" },
        -- Conform will use the first available formatter in the list
        javascript = { "prettier_d" },
        typescript = { "prettier_d" },
        vue = { "prettier_d" },
        -- Formatters can also be specified with additional options
        python = {
            formatters = { "isort", "black" },
            -- Run formatters one after another instead of stopping at the first success
            run_all_formatters = true,
            -- Don't run these formatters as part of the format_on_save autocmd (see below)
            format_on_save = false,
        },
        zig = { "zigfmt" },
    },
})