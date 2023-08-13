local opt = {
    settings = {
        pylsp = {
            plugins = {
                pycodestyle = {
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
            },
        },
    },
}

return opt
