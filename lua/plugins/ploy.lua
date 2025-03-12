return
--- @type LazySpec
{
    {
        "tamton-aquib/duck.nvim",
        event = "VeryLazy",
        config = function()
            vim.keymap.set("n", "<leader>dd", function()
                require("duck").hatch()
            end, { desc = "hatch a duck" })
            vim.keymap.set("n", "<leader>dk", function()
                require("duck").cook()
            end, { desc = "kill one duck" })
            vim.keymap.set("n", "<leader>da", function()
                require("duck").cook_all()
            end, { desc = "kill all ducks" })
        end,
    },
}
