return
--- @type LangSpec
{
    -- lsp = "golangci_lint_ls",
    opt = {
        init_options = {
            command = {
                "golangci-lint",
                "run",
                "--output.json.path",
                "stdout",
                "--show-stats=false",
                "--issues-exit-code=1",
            },
        },
    },
    lint = {},
    others = { "golangci-lint" },
    before_set = nil,
    after_set = nil,
    plugins = {},
}
