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
        "kdheepak/lazygit.nvim",
        event = "VeryLazy",
        cmd = {
            "LazyGit",
            "LazyGitConfig",
            "LazyGitCurrentFile",
            "LazyGitFilter",
            "LazyGitFilterCurrentFile",
        },
        -- optional for floating window border decoration
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        -- setting the keybinding for LazyGit with 'keys' is recommended in
        -- order to load the plugin when the command is run for the first time
        keys = {
            { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
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
}
