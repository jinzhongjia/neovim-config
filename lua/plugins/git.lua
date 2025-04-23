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
        opts = {
            mappings = {
                finder = {
                    ["<C-j>"] = "Next",
                    ["<C-k>"] = "Previous",
                },
            },
        },
        keys = {
            { "<leader>ng", "<cmd>Neogit<cr>", desc = "NeoGit" },
        },
    },
    {
        "sindrets/diffview.nvim",
        event = "VeryLazy",
    },
    {
        "FabijanZulj/blame.nvim",
        event = "VeryLazy",
        opts = {},
        keys = {
            { "<leader>bt", "<cmd>BlameToggle<cr>", desc = "Blame toogle" },
        },
    },
    {
        "akinsho/git-conflict.nvim",
        event = "VeryLazy",
        version = "*",
        config = true,
    },
}
