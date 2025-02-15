return
--- @type LazySpec
{
    {
        "echasnovski/mini.diff",
        version = "*",
        event = "VeryLazy",
        opts = {},
    },
    {
        "rbong/vim-flog",
        event = "VeryLazy",
        dependencies = {
            "tpope/vim-fugitive",
        },
    },
    {
        "NeogitOrg/neogit",
        dependencies = {
            "nvim-lua/plenary.nvim", -- required
            "sindrets/diffview.nvim", -- optional - Diff integration

            -- Only one of these is needed.
            "nvim-telescope/telescope.nvim", -- optional
        },
        event = "VeryLazy",
        config = true,
    },
    {
        "sindrets/diffview.nvim",
        event = "VeryLazy",
    },
    {
        "FabijanZulj/blame.nvim",
        lazy = false,
        opts = {},
        keys = {
            { "<leader>bt", "<cmd>BlameToggle<cr>", desc = "Blame toogle" },
        },
    },
}
