return
--- @type LazySpec
{
    {
        "voldikss/vim-floaterm",
        event = "VeryLazy",
        opts = {},
        keys = {
            { "<leader>ft", "<CMD>FloatermNew<CR>", mode = { "n", "t" }, desc = "floaterm new" },
            { "<leader>fj", "<CMD>FloatermPrev<CR>", mode = { "n", "t" }, desc = "floaterm prev" },
            { "<leader>fk", "<CMD>FloatermNext<CR>", mode = { "n", "t" }, desc = "floaterm next" },
            { "<leader>fs", "<CMD>FloatermToggle<CR>", mode = { "n", "t" }, desc = "floaterm toggel" },
            { "<leader>fc", "<CMD>FloatermKill<CR>", mode = { "n", "t" }, desc = "floaterm kill" },
        },
    },
}

