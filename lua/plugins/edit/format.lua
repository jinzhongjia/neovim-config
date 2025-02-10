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
                go = { "gofumpt", "goimports-reviser" },
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
                python = { "isort", "black" },
                zig = { "zigfmt" },
                markdown = { "prettierd", "cbfmt" },
                yaml = { "yamlfmt" },
                xml = { "xmlformat" },
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
        init = function()
            -- If you want the formatexpr, here is the place to set it
            vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
        end,
    },
}
