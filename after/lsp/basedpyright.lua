-- ~/.config/nvim/after/lsp/basedpyright.lua
return {
    settings = {
        basedpyright = {
            analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "workspace",
                typeCheckingMode = "standard",
            },
        },
    },
}
