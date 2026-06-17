return
--- @type LazySpec
{
    {
        "stevearc/conform.nvim",
        cmd = { "ConformInfo" },
        opts = {
            default_format_opts = {
                lsp_format = "fallback",
            },
            formatters_by_ft = {
                c = { "clang_format" },
                cpp = { "clang_format" },
                go = {
                    "goimports",
                    "gofumpt",
                },
                html = { "prettierd" },
                json = { "prettierd" },
                jsonc = { "prettierd" },
                rust = { "rustfmt" },
                bash = { "shfmt" },
                lua = { "stylua" },
                javascript = { "prettierd" },
                typescript = { "prettierd" },
                javascriptreact = { "prettierd" },
                typescriptreact = { "prettierd" },
                vue = { "prettierd" },
                python = {
                    "ruff_organize_imports",
                    "ruff_format",
                },
                zig = { "zigfmt" },
                markdown = { "prettierd" },
                yaml = { "yamlfmt" },
                proto = { "buf" },
                sql = { "sleek" },
            },
        },
        keys = {
            {
                -- Customize or remove this keymap to your liking
                "<leader>f",
                function()
                    require("conform").format({ async = true })
                end,
                mode = "n",
                desc = "Format buffer",
            },
        },
    },
}
