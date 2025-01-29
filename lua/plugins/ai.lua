return
--- @type LazySpec
{
    {
        "olimorris/codecompanion.nvim",
        event = "VeryLazy",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            {
                "zbirenbaum/copilot.lua",
                opts = {
                    suggestion = { enabled = false },
                    panel = { enabled = false },
                },
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
