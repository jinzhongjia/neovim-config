return
--- @type LangSpec
{
    lsp = "gopls",
    opt = {
        settings = {
            gopls = {
                hints = {
                    assignVariableTypes = true,
                    compositeLiteralFields = true,
                    compositeLiteralTypes = true,
                    constantValues = true,
                    functionTypeParameters = true,
                    parameterNames = true,
                    rangeVariableTypes = true,
                },
            },
        },
    },
    lint = {},
    others = { "gofumpt", "goimports-reviser", "delve" },
    before_set = nil,
    after_set = nil,
    plugins = {
        {
            "jinzhongjia/nvim-dap-go",
            event = "VeryLazy",
            dev = true,
            config = function()
                require("dap-go").setup()
            end,
        },
    },
}
