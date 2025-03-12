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
    {
        "eandrju/cellular-automaton.nvim",

        evnet = "VeryLazy",
        keys = {
            { "<leader>bu", "<cmd>CellularAutomaton make_it_rain<CR>", desc = "make it rain" },
            { "<leader>bi", "<cmd>CellularAutomaton game_of_life<CR>", desc = "game of life" },
        },
    },
}
