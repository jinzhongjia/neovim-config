-- setting for bufferline, lualine, auto sized window
vim.g.gitblame_display_virtual_text = 0

local is_insert = false
local is_blame = false

return
--- @type LazySpec
{
    {
        "akinsho/bufferline.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        event = "UIEnter",
        opts = {
            options = {
                -- To close the Tab command, use moll/vim-bbye's :Bdelete command here
                close_command = "Bdelete! %d",
                right_mouse_command = "Bdelete! %d",
                -- Using nvim's built-in LSP will be configured later in the course
                diagnostics = "nvim_lsp",
                -- Optional, show LSP error icon
                ---@diagnostic disable-next-line: unused-local
                diagnostics_indicator = function(count, level, diagnostics_dict, context)
                    local s = " "
                    for e, n in pairs(diagnostics_dict) do
                        local sym = e == "error" and "" or (e == "warning" and "" or "")
                        s = s .. n .. sym
                    end
                    return s
                end,
            },
        },
        keys = {
            { "bn", "<cmd>BufferLineCycleNext<cr>", desc = "bufferline next" },
            { "bp", "<cmd>BufferLineCyclePrev<cr>", desc = "bufferline prev" },
            { "bd", "<cmd>Bdelete<cr>", desc = "buffer delete" },
            { "<leader>bl", "<cmd>BufferLineCloseRight<cr>", desc = "bufferline close right" },
            { "<leader>bh", "<cmd>BufferLineCloseLeft<cr>", desc = "bufferline close left" },
            { "<leader>bn", "<cmd>BufferLineMoveNext<cr>", desc = "bufferline move next" },
            { "<leader>bp", "<cmd>BufferLineMovePrev<cr>", desc = "bufferline move prev" },
        },
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "f-person/git-blame.nvim",
            "jinzhongjia/LspUI.nvim",
        },
        event = "UIEnter",
        opts = {
            sections = {
                lualine_x = {
                    {
                        require("lazy.status").updates,
                        cond = require("lazy.status").has_updates,
                        color = { fg = "#ff9e64" },
                    },
                    "copilot",
                    "encoding",
                    "fileformat",
                    "filetype",
                },
                lualine_c = {
                    {
                        function()
                            if is_insert then
                                local signature = require("LspUI").api.signature()
                                if not signature then
                                    return ""
                                end
                                if not signature.hint then
                                    return signature.label
                                end

                                return signature.parameters[signature.hint].label
                            elseif is_blame then
                                return require("gitblame").get_current_blame_text()
                            end
                        end,
                        cond = function()
                            local mode_info = vim.api.nvim_get_mode()
                            local mode = mode_info["mode"]
                            is_insert = mode:find("i") ~= nil or mode:find("ic") ~= nil

                            local text = require("gitblame").get_current_blame_text()
                            if text then
                                is_blame = text ~= ""
                            else
                                is_blame = false
                            end

                            return is_insert or is_blame
                        end,
                    },
                },
            },
        },
    },
    {
        "anuvyklack/windows.nvim",
        event = "VeryLazy",
        dependencies = {
            "anuvyklack/middleclass",
        },
        opts = {
            ignore = {
                filetype = { "NvimTree", "undotree", "Outline" },
            },
        },
    },
    {
        "folke/trouble.nvim",
        opts = {
            modes = {
                test = {
                    mode = "diagnostics",
                    preview = {
                        type = "split",
                        relative = "win",
                        position = "right",
                        size = 0.3,
                    },
                },
            },
        }, -- for default options, refer to the configuration section for custom setup.
        cmd = "Trouble",
        keys = {
            {
                "<leader>xx",
                "<cmd>Trouble diagnostics toggle<cr>",
                desc = "Diagnostics (Trouble)",
            },
            {
                "<leader>xX",
                "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
                desc = "Buffer Diagnostics (Trouble)",
            },
            {
                "<leader>cs",
                "<cmd>Trouble symbols toggle focus=false<cr>",
                desc = "Symbols (Trouble)",
            },
            {
                "<leader>cl",
                "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
                desc = "LSP Definitions / references / ... (Trouble)",
            },
            {
                "<leader>xL",
                "<cmd>Trouble loclist toggle<cr>",
                desc = "Location List (Trouble)",
            },
            {
                "<leader>xQ",
                "<cmd>Trouble qflist toggle<cr>",
                desc = "Quickfix List (Trouble)",
            },
        },
    },
    {
        "stevearc/dressing.nvim",
        event = "VeryLazy",
        opts = {},
    },
    {
        "folke/zen-mode.nvim",
        event = "VeryLazy",
        dependencies = {
            "folke/twilight.nvim",
            opts = {},
        },
        opts = {},
    },
    {
        "jeffkreeftmeijer/vim-numbertoggle",
        event = "VeryLazy",
    },
    {
        "nacro90/numb.nvim",
        event = "VeryLazy",
        opts = {},
    },
    {
        "echasnovski/mini.animate",
        event = "VeryLazy",
        version = "*",
        opts = {},
    },
}
