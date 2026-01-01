return
--- @type LazySpec
{
    {
        "stevearc/oil.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        keys = {
            {
                "<leader>e",
                function()
                    require("oil").open()
                end,
                desc = "Open file explorer",
            },
        },
        opts = {
            default_file_explorer = true,
        },
    },
}
