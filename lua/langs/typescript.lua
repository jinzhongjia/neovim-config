return
--- @type LangSpec
{
    lsp = "vtsls",
    opt = {
        settings = {
            typescript = {
                inlayHints = {
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
    before_set = nil,
    after_set = nil,
    lint = { "ts-standard" },
    --- @type LazySpec
    plugins = {
        "dmmulroy/tsc.nvim",
        event = "VeryLazy",
        opts = {},
    },
}
