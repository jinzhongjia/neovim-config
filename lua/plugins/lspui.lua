return {

    {
        "jinzhongjia/LspUI.nvim",
        dev = true,
        event = "VeryLazy",
        opts = {
            signature = {
                enable = true,
            },
            inlay_hint = {
                enable = true,
            },
        },
        keys = {
            { "<leader>rn", "<cmd>LspUI rename<cr>",      desc = "Rename symbol" },
            { "<leader>ca", "<cmd>LspUI code_action<cr>", desc = "Code action" },
            {
                "K",
                function()
                    local winid = require("ufo").peekFoldedLinesUnderCursor()
                    if not winid then
                        vim.cmd("LspUI hover")
                    end
                end,
                desc = "Hover information",
            },
            { "gd", "<cmd>LspUI definition<cr>",              desc = "Go to definition" },
            { "gD", "<cmd>LspUI declaration<cr>",             desc = "Go to declaration" },
            { "gi", "<cmd>LspUI implementation<cr>",          desc = "Go to implementation" },
            { "gr", "<cmd>LspUI reference<cr>",               desc = "Find references" },
            { "gy", "<cmd>LspUI type_definition<cr>",         desc = "Go to type definition" },
            { "gk", "<cmd>LspUI diagnostic prev<cr>",         desc = "Previous diagnostic" },
            { "gj", "<cmd>LspUI diagnostic next<cr>",         desc = "Next diagnostic" },
            { "gh", "<cmd>LspUI call_hierarchy incoming<cr>", desc = "Call hierarchy (callers)" },
            { "gl", "<cmd>LspUI call_hierarchy outgoing<cr>", desc = "Call hierarchy (callees)" },
        },
    },
}
