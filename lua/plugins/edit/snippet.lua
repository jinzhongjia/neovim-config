---@diagnostic disable-next-line: param-type-mismatch
_G.my_snippets_path = vim.fs.normalize(vim.fs.joinpath(vim.fn.stdpath("config"), "/snippets"))

return
--- @type LazySpec
{
    {
        "chrisgrieser/nvim-scissors",
        event = "VeryLazy",
        dependencies = {
            "folke/snacks.nvim", -- 使用 snacks.nvim 作为 picker（已经在你的配置中）
        },
        opts = {
            snippetDir = my_snippets_path,
            snippetSelection = {
                picker = "snacks", -- 使用 snacks picker 替代 telescope
            },
        },
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
