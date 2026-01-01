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
    {
        "JezerM/oil-lsp-diagnostics.nvim",
        enabled = false, -- oil.nvim 已禁用
        dependencies = { "stevearc/oil.nvim" },
        opts = {},
    },
    {
        "refractalize/oil-git-status.nvim",
        enabled = false, -- oil.nvim 已禁用
        dependencies = { "stevearc/oil.nvim" },
        opts = {
            show_ignored = true,
        },
    },
}
