return {
    {
        "j-hui/fidget.nvim",
        event = "LspAttach",
        opts = {
            notification = {
                window = {
                    avoid = { "NvimTree" },
                },
            },
        },
    },
}
