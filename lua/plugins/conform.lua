return
--- @type LazySpec
{
    {
        "stevearc/conform.nvim",
        event = "VeryLazy",
        cmd = { "ConformInfo" },
        opts = {},
        keys = {
            {
                "<leader>f",
                function()
                    require("conform").format({
                        async = false,
                        lsp_fallback = true,
                    })
                end,
                mode = { "n", "v" },
                desc = "Format file or range",
            },
        },
    },
}

