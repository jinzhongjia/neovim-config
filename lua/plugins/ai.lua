return
--- @type LazySpec
{
    {
        "olimorris/codecompanion.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            {
                "zbirenbaum/copilot.lua",
                opts = {},
            },
        },
        opts = {
            strategies = {
                -- Change the default chat adapter
                chat = {
                    adapter = "copilot",
                },
                inline = {
                    adapter = "copilot",
                },
            },
        },
    },
}
