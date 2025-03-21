return
--- @type LangSpec
{
    lsp = "yamlls",
    opt = {
        settings = {
            yaml = {
                schemas = {
                    ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
                },
            },
        },
    },
    others = { "yamlfmt" },
    before_set = nil,
    after_set = nil,
    lint = {},
}
