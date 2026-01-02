-- cssls: CSS/SCSS/Less LSP
return {
    settings = {
        css = {
            validate = true,
            lint = {
                unknownAtRules = "ignore",
            },
        },
        scss = {
            validate = true,
        },
        less = {
            validate = true,
        },
    },
}
