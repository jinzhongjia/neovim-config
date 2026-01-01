-- ~/.config/nvim/after/lsp/gopls.lua
return {
    settings = {
        gopls = {
            -- 启用 gofumpt 进行更严格的格式化
            gofumpt = true,
            -- 启用 staticcheck 进行代码分析
            staticcheck = true,
            -- 启用所有分析器，例如 unusedparams
            analyses = {
                unusedparams = true,
            },
            -- 启用所有 inlay hints
            hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
            },
        },
    },
}

