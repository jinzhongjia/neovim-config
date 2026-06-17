return {
    settings = {
        vtsls = {
            autoUseWorkspaceTsdk = true,
            experimental = {
                completion = {
                    enableServerSideFuzzyMatch = true,
                    entriesLimit = 100,
                },
            },
        },
        typescript = {
            preferGoToSourceDefinition = true,
            updateImportsOnFileMove = { enabled = "always" },
            tsserver = {
                maxTsServerMemory = 8192,
            },
            suggest = {
                autoImports = true,
                completeFunctionCalls = true,
            },
            preferences = {
                importModuleSpecifier = "shortest",
                importModuleSpecifierEnding = "minimal",
                includePackageJsonAutoImports = "auto",
            },
            inlayHints = {
                parameterNames = { enabled = "all" },
                parameterTypes = { enabled = true },
                variableTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                enumMemberValues = { enabled = true },
            },
            implementationsCodeLens = {
                enabled = true,
                showOnInterfaceMethods = true,
            },
        },
        javascript = {
            preferGoToSourceDefinition = true,
            updateImportsOnFileMove = { enabled = "always" },
            suggest = {
                autoImports = true,
                completeFunctionCalls = true,
            },
            preferences = {
                importModuleSpecifier = "shortest",
                importModuleSpecifierEnding = "minimal",
                includePackageJsonAutoImports = "auto",
            },
            inlayHints = {
                parameterNames = { enabled = "all" },
                parameterTypes = { enabled = true },
                variableTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                enumMemberValues = { enabled = true },
            },
        },
    },
}
