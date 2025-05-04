return
--- @type LazySpec
{
    {
        "rest-nvim/rest.nvim",
        event = "VeryLazy",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
    },
    {
        "mistweaverco/kulala.nvim",
        event = "VeryLazy",
        opts = {
            -- your configuration comes here
            global_keymaps = false,
        },
    },
}
