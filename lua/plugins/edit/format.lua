local is_setting_custom_config = false
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
                    -- "gofumpt",
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
                    -- "isort",
                    -- "black",
                    "yapf",
                },
                zig = { "zigfmt" },
                markdown = { "prettierd" },
                yaml = { "yamlfmt" },
                proto = { "buf" },
                http = { "kulala-fmt" },
            },
        },
        keys = {
            {
                -- Customize or remove this keymap to your liking
                "<leader>f",
                function()
                    if not is_setting_custom_config then
                        require("conform").formatters["goimports-reviser"] = {
                            prepend_args = { "-imports-order=std,project,company,general " },
                        }
                    end
                    is_setting_custom_config = true
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
