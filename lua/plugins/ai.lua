return
--- @type LazySpec
{
    {
        "olimorris/codecompanion.nvim",
        event = "VeryLazy",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nvim-telescope/telescope.nvim",
            {
                "zbirenbaum/copilot.lua",
                opts = {
                    suggestion = { enabled = false },
                    panel = { enabled = false },
                    filetypes = {
                        ["*"] = false, -- disable for all other filetypes and ignore default `filetypes`
                        lua = true,
                        go = true,
                        zig = true,
                        typescript = true,
                        javascript = true,
                        vue = true,
                        c = true,
                        cpp = true,
                    },
                },
            },
        },
        opts = {
            display = {
                action_palette = {
                    provider = "telescope", -- default|telescope|mini_pick
                },
                chat = {
                    window = {
                        opts = {
                            relativenumber = false,
                            number = false,
                        },
                    },
                },
            },
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
