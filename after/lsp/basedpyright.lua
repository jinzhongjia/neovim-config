-- ~/.config/nvim/after/lsp/basedpyright.lua
return {
    settings = {
        basedpyright = {
            analysis = {
                -- 仅分析打开的文件，提高大型项目性能
                diagnosticMode = "openFilesOnly",
                -- 启用 inlay hints
                inlayHints = {
                    callArgumentNames = true,
                    functionReturnTypes = true,
                    variableTypes = true,
                },
            },
        },
    },
}
