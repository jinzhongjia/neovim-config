-- ~/.config/nvim/after/lsp/gopls.lua
return {
    settings = {
        gopls = {
            analyses = {
                -- 变量命名规范检查
                ST1003 = true,
            },
            -- 启用 gofumpt 进行更严格的格式化
            gofumpt = false,
            -- 启用语义令牌支持
            semanticTokens = true,
            -- 启用 staticcheck 进行代码分析
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
