return
--- @type LazySpec
{
    {
        "hedyhli/outline.nvim",
        event = "VeryLazy",
        cmd = { "Outline", "OutlineOpen", "OutlineFocus" },
        opts = {},
        keys = { -- Example mapping to toggle outline
            { "<leader>ao", "<cmd>Outline<CR>", desc = "Toggle outline" },
        },
    },
}

