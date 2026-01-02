return
--- @type LazySpec
{
    {
        "stevearc/conform.nvim",
        event = "VeryLazy",
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
                    "goimports-reviser",
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
                    "yapf",
                },
                zig = { "zigfmt" },
                markdown = { "prettierd" },
                yaml = { "yamlfmt" },
                proto = { "buf" },
                http = { "kulala-fmt" },
            },
            formatters = {
                ["goimports-reviser"] = {
                    command = "goimports-reviser",
                    prepend_args = { "-imports-order=std,project,company,general " },
                },
            },
        },
        keys = {
            {
                -- Customize or remove this keymap to your liking
                "<leader>f",
                function()
                    require("conform").format({ async = false })
                end,
                mode = "n",
                desc = "Format buffer",
            },
        },
    },
}
