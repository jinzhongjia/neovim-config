-- ~/.config/nvim/after/lsp/gopls.lua
return {
    settings = {
        gopls = {
            -- 缩小 gopls 索引范围：大型项目首次加载最大的杠杆。
            -- 排除无关目录，gopls 就不会去 go list / 类型检查它们。
            -- "-" 前缀表示排除，顺序生效（后面的可覆盖前面的）。
            directoryFilters = {
                "-vendor",
                "-node_modules",
                "-.git",
                "-bazel-bin",
                "-bazel-out",
                "-bazel-testlogs",
                "-testdata",
            },
            analyses = {
                -- 变量命名规范检查
                ST1003 = true,
            },
            -- 启用 gofumpt 进行更严格的格式化
            gofumpt = false,
            -- 启用语义令牌支持
            semanticTokens = true,
            -- 启用 staticcheck 进行代码分析(保留)
            staticcheck = true,
            -- 启用所有 inlay hints
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
