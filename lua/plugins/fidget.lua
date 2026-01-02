return {
    {
        "j-hui/fidget.nvim",
        event = "VeryLazy",
        opts = {
            notification = {
                window = {
                    avoid = { "NvimTree" },
                },
            },
            integration = {
                ["nvim-tree"] = { enable = false },
            },
        },
    },
}
