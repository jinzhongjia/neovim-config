return
--- @type LangSpec
{
    lsp = "vtsls",
    opt = {
        settings = {
            typescript = {
                inlayHints = {
                    parameterNames = { enabled = "literals" },
                    parameterTypes = { enabled = true },
                    variableTypes = { enabled = true },
                    propertyDeclarationTypes = { enabled = true },
                    functionLikeReturnTypes = { enabled = true },
                    enumMemberValues = { enabled = true },
                },
            },
            javascript = {
                inlayHints = {
                    parameterTypes = { enabled = true },
                    variableTypes = { enabled = true },
                    propertyDeclarationTypes = { enabled = true },
                    functionLikeReturnTypes = { enabled = true },
                    enumMemberValues = { enabled = true },
                },
            },
        },
    },
    others = { "prettierd" },
    before_set = function()
        require("vtsls").config({})
        vim.lsp.config("vtsls", require("vtsls").lspconfig)
    end,
    after_set = nil,
    lint = {},
    plugins = {
        {
            "dmmulroy/tsc.nvim",
            event = "VeryLazy",
            opts = {},
        },
        {
            "yioneko/nvim-vtsls",
            event = "VeryLazy",
        },
    },
}
