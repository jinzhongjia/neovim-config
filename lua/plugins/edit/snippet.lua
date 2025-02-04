---@diagnostic disable-next-line: param-type-mismatch
local my_snippets = vim.fs.normalize(vim.fs.joinpath(vim.fn.stdpath("config"), "/snippets"))

return
--- @type LazySpec
{
    {
        "chrisgrieser/nvim-scissors",
        event = "VeryLazy",
        dependencies = {
            "nvim-telescope/telescope.nvim",
            {
                "garymjr/nvim-snippets",
                opts = { search_paths = { my_snippets } },
            },
        },
        opts = { snippetDir = my_snippets },
        keys = {
            {
                "<leader>se",
                function()
                    require("scissors").editSnippet()
                end,
                mode = "n",
                desc = "Snippet: Edit",
            },
            {
                "<leader>sa",
                function()
                    require("scissors").addNewSnippet()
                end,
                mode = { "n", "x" },
                desc = "Snippet: Add",
            },
        },
    },
}
