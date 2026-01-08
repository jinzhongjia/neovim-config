return
--- @type LazySpec
{
    {
        "nvim-lualine/lualine.nvim",
        event = "VimEnter",
        dependencies = { "nvim-tree/nvim-web-devicons", "SmiteshP/nvim-navic", "AndreM222/copilot-lualine" },
        config = function()
            -- Tokyo Night 风格颜色
            local colors = {
                bg = "#1a1b26",
                fg = "#c0caf5",
                blue = "#7aa2f7",
                green = "#9ece6a",
                purple = "#bb9af7",
                orange = "#e0af68",
                red = "#f7768e",
                peach = "#f5a97f",
                gray = "#565f89",
                black = "#000000",
                white = "#ffffff",
            }

            -- DAP UI filetypes 配置
            local dapui_filetypes = {
                dapui_scopes = { icon = "", label = "Scopes" },
                dapui_breakpoints = { icon = "", label = "Breakpoints" },
                dapui_stacks = { icon = "", label = "Stacks" },
                dapui_watches = { icon = "", label = "Watches" },
                ["dap-repl"] = { icon = "", label = "REPL" },
                dapui_console = { icon = "", label = "Console" },
            }

            -- 特殊窗口配置
            local special_filetypes = {
                NvimTree = { icon = "", label = "NvimTree", color = colors.green },
                Outline = { icon = "", label = "Outline", color = colors.blue },
                opencode = { icon = "", label = "OpenCode", color = colors.red },
                opencode_output = { icon = "", label = "OpenCode Output", color = colors.orange },
                NeogitStatus = { icon = "", label = "Neogit", color = colors.peach },
            }

            -- CodeCompanion 模型名称
            local function codecompanion_model()
                local bufnr = vim.api.nvim_get_current_buf()
                local metadata = _G.codecompanion_chat_metadata and _G.codecompanion_chat_metadata[bufnr]
                if metadata and metadata.model then
                    return "󰘦 " .. metadata.model
                end
                return ""
            end

            -- CodeCompanion Tokens
            local function codecompanion_tokens()
                local bufnr = vim.api.nvim_get_current_buf()
                local metadata = _G.codecompanion_chat_metadata and _G.codecompanion_chat_metadata[bufnr]
                if metadata and metadata.tokens then
                    return "󰆾 " .. metadata.tokens
                end
                return ""
            end

            -- DAP UI 扩展
            local dapui_extension = {
                sections = {
                    lualine_a = {
                        {
                            function()
                                local ft = vim.bo.filetype
                                local info = dapui_filetypes[ft] or { icon = "", label = ft }
                                return info.icon .. " " .. info.label
                            end,
                            color = { fg = colors.black, bg = colors.red, gui = "bold" },
                        },
                    },
                    lualine_b = {},
                    lualine_c = {},
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = { "location" },
                },
                filetypes = vim.tbl_keys(dapui_filetypes),
            }

            -- CodeCompanion 扩展
            local codecompanion_extension = {
                sections = {
                    lualine_a = {
                        {
                            function()
                                return "󰚩 CodeCompanion"
                            end,
                            color = { fg = colors.black, bg = colors.purple, gui = "bold" },
                        },
                    },
                    lualine_b = {
                        { codecompanion_model, color = { fg = colors.blue, bg = colors.bg } },
                    },
                    lualine_c = {},
                    lualine_x = {
                        { codecompanion_tokens, color = { fg = colors.green, bg = colors.bg } },
                    },
                    lualine_y = {},
                    lualine_z = { "location" },
                },
                filetypes = { "codecompanion" },
            }

            -- 特殊窗口扩展生成器
            local function create_special_extension(ft, info)
                return {
                    sections = {
                        lualine_a = {
                            {
                                function()
                                    return info.icon .. " " .. info.label
                                end,
                                color = { fg = colors.black, bg = info.color, gui = "bold" },
                            },
                        },
                        lualine_b = {},
                        lualine_c = {},
                        lualine_x = {},
                        lualine_y = {},
                        lualine_z = { "location" },
                    },
                    filetypes = { ft },
                }
            end

            -- 生成所有特殊窗口扩展
            local special_extensions = {}
            for ft, info in pairs(special_filetypes) do
                table.insert(special_extensions, create_special_extension(ft, info))
            end

            -- Winbar 禁用的 filetypes
            local winbar_disabled_ft = vim.tbl_keys(special_filetypes)
            vim.list_extend(winbar_disabled_ft, vim.tbl_keys(dapui_filetypes))
            vim.list_extend(winbar_disabled_ft, { "gitcommit", "gitrebase", "hgcommit", "codecompanion", "" })

            -- Navic 组件
            local function navic_location()
                local navic = require("nvim-navic")
                if navic.is_available() then
                    local location = navic.get_location()
                    if location ~= "" then
                        return " › " .. location
                    end
                end
                return ""
            end

            -- 合并所有需要隐藏默认状态栏的 filetypes
            local all_special_ft = vim.tbl_keys(special_filetypes)
            vim.list_extend(all_special_ft, vim.tbl_keys(dapui_filetypes))
            vim.list_extend(all_special_ft, { "codecompanion" })

            -- 检测是否为特殊 filetype
            local function is_special_ft()
                return vim.tbl_contains(all_special_ft, vim.bo.filetype)
            end

            -- 合并所有扩展
            local extensions = { dapui_extension, codecompanion_extension }
            vim.list_extend(extensions, special_extensions)

            require("lualine").setup({
                options = {
                    theme = "auto",
                    component_separators = "",
                    section_separators = "",
                    globalstatus = false,
                    disabled_filetypes = {
                        winbar = winbar_disabled_ft,
                    },
                },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = {
                        { "branch", icon = "", color = { fg = colors.peach, gui = "bold" } },
                    },
                    lualine_c = {
                        { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
                        {
                            "filename",
                            path = 0,
                            symbols = { modified = " ●", readonly = " ", unnamed = "[No Name]" },
                        },
                    },
                    lualine_x = {
                        {
                            "copilot",
                            show_colors = true,
                            symbols = {
                                status = {
                                    hl = {
                                        enabled = colors.green,
                                        sleep = colors.gray,
                                        disabled = colors.gray,
                                        warning = colors.orange,
                                        unknown = colors.red,
                                    },
                                },
                                spinners = "dots",
                                spinner_color = colors.blue,
                            },
                        },
                    },
                    lualine_y = {
                        { "filetype", colored = false, color = { fg = colors.blue } },
                    },
                    lualine_z = {
                        {
                            function()
                                local line = vim.api.nvim_win_get_cursor(0)[1]
                                local col = vim.api.nvim_win_get_cursor(0)[2] + 1
                                local lines = vim.api.nvim_buf_line_count(0)
                                return string.format("%d/%d:%d", line, lines, col)
                            end,
                        },
                    },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { "filename" },
                    lualine_x = { "location" },
                    lualine_y = {},
                    lualine_z = {},
                },
                winbar = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = {
                        {
                            "filename",
                            path = 1, -- 相对路径
                            color = { fg = colors.blue },
                        },
                        {
                            navic_location,
                            color = { fg = colors.gray },
                        },
                    },
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = {},
                },
                inactive_winbar = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = {
                        {
                            "filename",
                            path = 1,
                            color = { fg = colors.gray },
                        },
                    },
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = {},
                },
                extensions = extensions,
            })
        end,
    },
}
