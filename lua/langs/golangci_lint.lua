return
--- @type LangSpec
{
    lsp = "golangci_lint_ls",
    opt = {
        -- for v1
        init_options = {
            command = { "golangci-lint", "run", "--out-format", "json" },
        },
        -- init_options = {
        --     command = {
        --         "golangci-lint",
        --         "run",
        --         "--output.json.path",
        --         "stdout",
        --         "--show-stats=false",
        --         "--issues-exit-code=1",
        --     },
        -- },
    },
    lint = {},
    others = {
        { name = "golangci-lint", version = "v1.64.8" },
    },
    before_set = nil,
    after_set = nil,
    plugins = {},
}
