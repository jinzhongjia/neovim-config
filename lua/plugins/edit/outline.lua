return
--- @type LazySpec
{
    {
        "hedyhli/outline.nvim",
        lazy = true,
        cmd = { "Outline", "OutlineOpen" },
        keys = { -- Example mapping to toggle outline
            { "<leader>a", "<cmd>Outline<CR>", desc = "Toggle outline" },
        },
        opts = {},
    },
}
