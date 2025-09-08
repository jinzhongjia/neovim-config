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
                enable = true,
            },
        },
        keys = {
            { "<leader>rn", "<cmd>LspUI rename<cr>", desc = "LspUI rename" },
            { "<leader>ca", "<cmd>LspUI code_action<cr>", desc = "LspUI code action" },
            {
                "K",
                function()
                    local winid = require("ufo").peekFoldedLinesUnderCursor()
                    if not winid then
                        vim.cmd("LspUI hover")
                    end
                end,
                desc = "LspUI hover",
            },
            { "gd", "<cmd>LspUI definition<cr>", desc = "LspUI definition" },
            { "gD", "<cmd>LspUI declaration<cr>", desc = "LspUI declaration" },
            { "gi", "<cmd>LspUI implementation<cr>", desc = "LspUI implementation" },
            { "gr", "<cmd>LspUI reference<cr>", desc = "LspUI reference" },
            { "gy", "<cmd>LspUI type_definition<cr>", desc = "LspUI type definition" },
            { "gk", "<cmd>LspUI diagnostic prev<cr>", desc = "LspUI diagnostic prev" },
            { "gj", "<cmd>LspUI diagnostic next<cr>", desc = "LspUI diagnostic next" },
            { "gh", "<cmd>LspUI call_hierarchy incoming<cr>", desc = "LspUI call hierarchy incoming" },
            { "gl", "<cmd>LspUI call_hierarchy outgoing<cr>", desc = "LspUI call hierarchy outgoing" },
        },
    },
    {
        "Bekaboo/dropbar.nvim",
        event = "VeryLazy",
        dependencies = {
            "nvim-telescope/telescope-fzf-native.nvim",
        },
        config = function()
            require("dropbar").setup({
                bar = {
                    enable = function(buf, win, _)
                        local excluded_filetypes = {
                            help = true,
                            codecompanion = true,
                            -- 可以在这里添加更多需要排除的 filetype
                        }

                        return not vim.w[win].winbar_no_attach
                            and vim.api.nvim_buf_is_valid(buf)
                            and vim.api.nvim_win_is_valid(win)
                            and vim.wo[win].winbar == ""
                            and vim.fn.win_gettype(win) == ""
                            and not excluded_filetypes[vim.bo[buf].ft]
                            and ((pcall(vim.treesitter.get_parser, buf)) and true or false)
                    end,
                },
            })
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
