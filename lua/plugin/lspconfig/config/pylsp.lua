local opt = {
    settings = {
        pylsp = {
            plugins = {
                pycodestyle = {
                    enabled = true,
                    ignore = { "W391" },
                    maxLineLength = 100,
                },
                flake8 = {
                    enabled = true,
                },
                rope_autoimport = {
                    enabled = true,
                },
                rope_completion = {
                    enabled = true,
                },
                jedi_completion = {
                    fuzzy = true,
                    eager = true,
                },
                pylint = {
                    enabled = true,
                },
            },
        },
    },
}

return opt
