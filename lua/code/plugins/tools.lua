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
        "gbprod/yanky.nvim",
        event = "VeryLazy",
        opts = {},
        keys = {
            {
                "<leader>p",
                function()
                    require("telescope").extensions.yank_history.yank_history({})
                end,
                desc = "Open Yank History",
            },
            { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank text" },
            { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put yanked text after cursor" },
            { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put yanked text before cursor" },
            { "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" }, desc = "Put yanked text after selection" },
            { "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" }, desc = "Put yanked text before selection" },
            { "]p", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put indented after cursor (linewise)" },
            { "[p", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put indented before cursor (linewise)" },
            { "]P", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put indented after cursor (linewise)" },
            { "[P", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put indented before cursor (linewise)" },
            { ">p", "<Plug>(YankyPutIndentAfterShiftRight)", desc = "Put and indent right" },
            { "<p", "<Plug>(YankyPutIndentAfterShiftLeft)", desc = "Put and indent left" },
            { ">P", "<Plug>(YankyPutIndentBeforeShiftRight)", desc = "Put before and indent right" },
            { "<P", "<Plug>(YankyPutIndentBeforeShiftLeft)", desc = "Put before and indent left" },
            { "=p", "<Plug>(YankyPutAfterFilter)", desc = "Put after applying a filter" },
            { "=P", "<Plug>(YankyPutBeforeFilter)", desc = "Put before applying a filter" },
        },
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
