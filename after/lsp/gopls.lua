return {
    settings = {
        gopls = {
            -- 缩小 gopls 索引范围：大型项目首次加载最大的杠杆。
            -- "-" 前缀表示排除，顺序生效（后面的可覆盖前面的）。
            directoryFilters = {
                "-vendor",
                "-node_modules",
                "-.git",
                "-bazel-bin",
                "-bazel-out",
                "-bazel-testlogs",
            },
            analyses = {
                ST1003 = true,
                nilness = true,
                shadow = true,
                unusedparams = true,
                unusedwrite = true,
                useany = true,
            },
            codelenses = {
                gc_details = true,
                generate = true,
                regenerate_cgo = true,
                run_govulncheck = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
            },
            completeUnimported = true,
            deepCompletion = true,
            gofumpt = true,
            semanticTokens = true,
            staticcheck = true,
            usePlaceholders = true,
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
}
