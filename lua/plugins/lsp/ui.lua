local transparency = vim.g.neovide and 45 or 0

return
--- @type LazySpec
{
    {
        "j-hui/fidget.nvim",
        event = "VeryLazy",
        opts = {},
    },
    {
        "jinzhongjia/LspUI.nvim",
        dev = true,
        event = "VeryLazy",
        opts = {
            hover = {
                transparency = transparency,
            },
            rename = {
                transparency = transparency,
            },
            code_action = {
                transparency = transparency,
            },
            diagnostic = {
                transparency = transparency,
            },
            pos_keybind = {
                transparency = transparency,
            },
            signature = {
                enable = true,
            },
            inlay_hint = {
                enable = false,
            },
        },
        keys = {
            { "<leader>rn", "<cmd>LspUI rename<cr>", desc = "LspUI rename" },
            { "<leader>ca", "<cmd>LspUI code_action<cr>", desc = "LspUI code action" },
            { "gd", "<cmd>LspUI definition<cr>", desc = "LspUI definition" },
            { "K", "<cmd>LspUI hover<cr>", desc = "LspUI hover" },
            { "gD", "<cmd>LspUI declaration<cr>", desc = "LspUI declaration" },
            { "gi", "<cmd>LspUI implementation<cr>", desc = "LspUI implementation" },
            { "gr", "<cmd>LspUI reference<cr>", desc = "LspUI reference" },
            { "gk", "<cmd>LspUI diagnostic prev<cr>", desc = "LspUI diagnostic prev" },
            { "gj", "<cmd>LspUI diagnostic next<cr>", desc = "LspUI diagnostic next" },
            { "gy", "<cmd>LspUI type_definition<cr>", desc = "LspUI type definition" },
        },
    },
    {
        "Bekaboo/dropbar.nvim",
        event = "VeryLazy",
        dependencies = {
            "nvim-telescope/telescope-fzf-native.nvim",
        },
        config = function()
            local dropbar_api = require("dropbar.api")
            vim.keymap.set("n", "<Leader>;", dropbar_api.pick, { desc = "Pick symbols in winbar" })
            vim.keymap.set("n", "[;", dropbar_api.goto_context_start, { desc = "Go to start of current context" })
            vim.keymap.set("n", "];", dropbar_api.select_next_context, { desc = "Select next context" })
        end,
    },
    {
        "zbirenbaum/neodim",
        event = "LspAttach",
        opts = {},
    },
}
