return {
    settings = {
        validate = "on",
        run = "onType",
        format = false,
        workingDirectory = { mode = "auto" },
        codeAction = {
            disableRuleComment = {
                enable = true,
                location = "separateLine",
            },
            showDocumentation = {
                enable = true,
            },
        },
        codeActionOnSave = {
            enable = false,
            mode = "all",
        },
        problems = {
            shortenToSingleLine = false,
        },
    },
}
