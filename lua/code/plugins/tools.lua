return {
    { "tpope/vim-repeat" },
    {
        "Wansmer/treesj",
        event = "VeryLazy",
        keys = { "<space>m", "<space>j", "<space>s" },
        dependencies = { "nvim-treesitter/nvim-treesitter" }, -- if you install parsers with `nvim-treesitter`
        opts = {},
    },
    {
        "kylechui/nvim-surround",
        version = "*", -- Use for stability; omit to use `main` branch for the latest features
        event = "VeryLazy",
        opts = {},
    },
    {
        "echasnovski/mini.move",
        version = "*",
        opt = {},
    },
    {
        "nacro90/numb.nvim",
        event = "VeryLazy",
        opts = {
            number_only = true,
        },
    },
}
