-- CMake Language Server configuration
return {
    settings = {
        cmake = {
            -- Enable CMake LSP capabilities
            enable = true,
            -- Root markers for detecting CMake projects
            rootPatterns = { "CMakeLists.txt", ".git", ".cmake-format.yaml" },
            -- Build directory patterns
            buildDirectory = "build",
            -- Path to CMakeLists.txt relative to workspace root (optional)
            codeModel = {
                kind = "codemodel",
                -- Version of the codemodel
                version = {
                    major = 2,
                    minor = 0,
                },
            },
        },
    },
}
