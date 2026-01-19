return
--- @type LazySpec
{
    {
        "Wansmer/treesj",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        opts = {
            use_default_keymaps = false,
            max_join_length = 120,
        },
        keys = {
            {
                "<leader>m",
                function()
                    require("treesj").toggle()
                end,
                desc = "Toggle split/join",
            },
        },
    },
}
