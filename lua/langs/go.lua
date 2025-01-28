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
    lint = { "golangci-lint" },
    others = { "gofumpt", "goimports-reviser" },
    before_set = nil,
    after_set = nil,
}
