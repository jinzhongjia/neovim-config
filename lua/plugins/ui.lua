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
                indicator = {
                    style = "icon",
                    icon = " ",
                },
                offsets = {
                    { filetype = "NvimTree", text = "EXPLORER", text_align = "center" },
                    { filetype = "Outline", text = "OUTLINE", text_align = "center" },
                    { filetype = "codecompanion", text = "CodeCompanion", text_align = "center" },
                },
                show_tab_indicators = true,
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
        "francescarpi/buffon.nvim",
        enabled = false,
        ---@type BuffonConfig
        opts = {
            keybindings = {
                goto_next_buffer = "false",
                goto_previous_buffer = "false",
                close_others = "false",
            },
            --- Add your config here
        },
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "nvim-lua/plenary.nvim",
        },
    },
    {
        "leath-dub/snipe.nvim",
        enabled = false,
        event = "VeryLazy",
        -- stylua: ignore
        keys = {
            { "<leader>gb", function() require("snipe").open_buffer_menu() end, desc = "Open Snipe buffer menu" },
        },
        opts = {},
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "f-person/git-blame.nvim",
            "jinzhongjia/LspUI.nvim",
            {
                "AndreM222/copilot-lualine",
                dependencies = "zbirenbaum/copilot.lua",
            },
        },
        event = "UIEnter",
        opts = function()
              local special_filetypes = { "NvimTree", "Outline", "grug-far", "codecompanion", "snacks_terminal" }

            -- 检查当前 buffer 是否是特殊 filetype
            local function is_special_filetype()
                local ft = vim.bo.filetype
                for _, special_ft in ipairs(special_filetypes) do
                    if ft == special_ft then
                        return true
                    end
                end
                return false
            end

            return {
                options = {
                    theme = "vscode",
                    disabled_filetypes = {
                        statusline = {}, -- 不再禁用任何 filetype
                        winbar = {},
                    },
                },
                sections = {
                    lualine_a = {
                        {
                            "mode",
                            -- mode 组件始终显示
                        },
                    },
                    lualine_b = {
                        {
                            "branch",
                            cond = function()
                                return not is_special_filetype()
                            end,
                        },
                        {
                            "diff",
                            cond = function()
                                return not is_special_filetype()
                            end,
                        },
                        {
                            "diagnostics",
                            cond = function()
                                return not is_special_filetype()
                            end,
                        },
                    },
                    lualine_c = {
                        {
                            function()
                                if is_insert then
                                    local signature = require("LspUI").api.signature()
                                    if not signature then
                                        return ""
                                    end
                                    if not signature.active_parameter then
                                        return signature.label
                                    end

                                    return signature.parameters[signature.active_parameter].label
                                elseif is_blame then
                                    return require("gitblame").get_current_blame_text()
                                end
                            end,
                            cond = function()
                                -- 特殊 filetype 不显示这个组件
                                if is_special_filetype() then
                                    return false
                                end

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
                        {
                            "filename",
                            cond = function()
                                return not is_special_filetype()
                            end,
                        },
                    },
                    lualine_x = {
                        {
                            require("lazy.status").updates,
                            cond = function()
                                return require("lazy.status").has_updates() and not is_special_filetype()
                            end,
                            color = { fg = "#ff9e64" },
                        },
                        {
                            "copilot",
                            cond = function()
                                return not is_special_filetype()
                            end,
                        },
                        {
                            "encoding",
                            cond = function()
                                return not is_special_filetype()
                            end,
                        },
                        {
                            "fileformat",
                            cond = function()
                                return not is_special_filetype()
                            end,
                        },
                        {
                            "filetype",
                            -- filetype 组件始终显示
                        },
                    },
                    lualine_y = {
                        {
                            "progress",
                            cond = function()
                                return not is_special_filetype()
                            end,
                        },
                    },
                    lualine_z = {
                        {
                            "location",
                            cond = function()
                                return not is_special_filetype()
                            end,
                        },
                    },
                },
            }
        end,
    },
    {
        "anuvyklack/windows.nvim",
        event = "VeryLazy",
        dependencies = {
            "anuvyklack/middleclass",
        },
        opts = {
            ignore = {
                filetype = {
                    "NvimTree",
                    "undotree",
                    "Outline",
                    "codecompanion",
                    "grug-far",
                    "grug-far-history",
                    "Mundo",
                },
            },
        },
    },
    {
        "folke/trouble.nvim",
        event = "VeryLazy",
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
        keys = {
            -- stylua: ignore
            { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
            { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
            { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
            { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
            -- { "gd", "<cmd>Trouble lsp_definitions<cr>", desc = "LspUI definition" },
            -- { "gf", "<cmd>Trouble lsp_declarations<cr>", desc = "Trouble declaration" },
            -- { "gi", "<cmd>Trouble lsp_implementations<cr>", desc = "Trouble implementation" },
            -- { "gr", "<cmd>Trouble lsp_references<cr>", desc = "Trouble reference" },
            -- { "gy", "<cmd>Trouble lsp_type_definitions<cr>", desc = "Trouble type definition" },
            -- { "gci", "<cmd>Trouble lsp_incoming_calls<cr>", desc = "Trouble incoming calls" },
            -- { "gco", "<cmd>Trouble lsp_outgoing_calls<cr>", desc = "Trouble outgoing calls" },
        },
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
        opts = {
            number_only = true,
        },
    },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {},
        keys = {
            {
                "<leader>?",
                function()
                    require("which-key").show({ global = false })
                end,
                desc = "Buffer Local Keymaps (which-key)",
            },
        },
    },
    {
        -- 这个插件也不错
        "OXY2DEV/markview.nvim",
        enabled = false,
        opts = {
            preview = {
                filetypes = { "markdown", "codecompanion", "LspUI_hover" },
                ignore_buftypes = {},
            },
        },
    },
    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
        ft = { "markdown", "codecompanion", "LspUI_hover" },
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {
            checkbox = {
                unchecked = { icon = "✘ " },
                checked = { icon = "✔ " },
                custom = { todo = { rendered = "◯ " } },
            },
            html = {
                enabled = true,
                tag = {
                    buf = { icon = " ", highlight = "CodeCompanionChatVariable" },
                    file = { icon = " ", highlight = "CodeCompanionChatVariable" },
                    help = { icon = "󰘥 ", highlight = "CodeCompanionChatVariable" },
                    image = { icon = " ", highlight = "CodeCompanionChatVariable" },
                    symbols = { icon = " ", highlight = "CodeCompanionChatVariable" },
                    url = { icon = "󰖟 ", highlight = "CodeCompanionChatVariable" },
                    var = { icon = " ", highlight = "CodeCompanionChatVariable" },
                    tool = { icon = " ", highlight = "CodeCompanionChatTool" },
                    user = { icon = " ", highlight = "CodeCompanionChatTool" },
                    group = { icon = " ", highlight = "CodeCompanionChatToolGroup" },
                },
            },
        },
    },
    {
        "hat0uma/csvview.nvim",
        cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
        opts = {},
    },
    {
        "yorickpeterse/nvim-window",
        keys = {
            { "<leader>wj", "<cmd>lua require('nvim-window').pick()<cr>", desc = "nvim-window: Jump to window" },
        },
        config = true,
    },
}
