return
--- @type LazySpec
{
    {
        "hedyhli/outline.nvim",
        event = "VeryLazy",
        cmd = { "Outline", "OutlineOpen" },
        keys = { -- Example mapping to toggle outline
            { "<leader>a", "<cmd>Outline<CR>", desc = "Toggle outline" },
        },
        opts = {},
    },
}
