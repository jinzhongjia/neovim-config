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
                mode = "buffers", -- 显示 buffers 而不是 tabs
                always_show_bufferline = true, -- 始终显示 bufferline
                indicator = {
                    style = "icon",
                    icon = " ",
                },
                -- separator_style = "slant", -- 分隔符样式
                -- show_buffer_close_icons = true,
                -- show_close_icon = true,
                -- color_icons = true,
                offsets = {
                    { filetype = "NvimTree", text = "EXPLORER", text_align = "center" },
                    { filetype = "Outline", text = "OUTLINE", text_align = "center" },
                    { filetype = "codecompanion", text = "CodeCompanion", text_align = "center" },
                },
                show_tab_indicators = true,
                -- Use snacks.nvim's bufdelete for smart buffer deletion
                close_command = function(bufnr)
                    require("snacks").bufdelete(bufnr)
                end,
                right_mouse_command = function(bufnr)
                    require("snacks").bufdelete(bufnr)
                end,
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
                -- 自定义过滤器，可以过滤某些 buffer 类型
                custom_filter = function(buf_number, buf_numbers)
                    -- 过滤 quickfix 等特殊 buffer
                    if vim.bo[buf_number].buftype ~= "" then
                        return false
                    end
                    return true
                end,
            },
        },
        keys = {
            { "bn", "<cmd>BufferLineCycleNext<cr>", desc = "bufferline next" },
            { "bp", "<cmd>BufferLineCyclePrev<cr>", desc = "bufferline prev" },
            {
                "bd",
                function()
                    require("snacks").bufdelete()
                end,
                desc = "buffer delete",
            },
            { "<leader>bl", "<cmd>BufferLineCloseRight<cr>", desc = "bufferline close right" },
            { "<leader>bh", "<cmd>BufferLineCloseLeft<cr>", desc = "bufferline close left" },
            { "<leader>bn", "<cmd>BufferLineMoveNext<cr>", desc = "bufferline move next" },
            { "<leader>bp", "<cmd>BufferLineMovePrev<cr>", desc = "bufferline move prev" },
        },
    },
    {
        -- scope.nvim 提供 tab 级别的 buffer 隔离
        "tiagovla/scope.nvim",
        event = "TabNew", -- tab 操作时加载
        config = function()
            require("scope").setup({
                hooks = {
                    pre_tab_enter = function()
                        -- 进入 tab 前的自定义逻辑
                    end,
                    post_tab_enter = function()
                        -- 进入 tab 后的自定义逻辑
                    end,
                },
            })
        end,
        keys = {
            { "<leader>bm", "<cmd>ScopeMoveBuf<cr>", desc = "Move buffer to another tab" },
            {
                "<leader>fb",
                function()
                    -- 使用 fzf-lua 显示当前 tab 的 buffers
                    require("fzf-lua").buffers({
                        fzf_opts = {
                            ["--header"] = "Buffers in current tab",
                        },
                    })
                end,
                desc = "Find buffers in current tab",
            },
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
        -- 按键触发即可
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
            -- CodeCompanion Spinner 组件已被移除

            local special_filetypes = {
                "NvimTree",
                "Outline",
                "grug-far",
                "codecompanion",
                "snacks_terminal",
                -- dapui: 在这些窗口中隐藏状态栏/不渲染组件
                "dapui_scopes",
                "dapui_stacks",
                "dapui_watches",
                "dapui_breakpoints",
                "dapui_console",
                "dapui_repl",
                "dap-repl",
            }

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
                    globalstatus = false,
                    theme = "vscode",
                    disabled_filetypes = {
                        statusline = {
                            -- dapui 相关窗口禁用状态栏
                            "dapui_scopes",
                            "dapui_stacks",
                            "dapui_watches",
                            "dapui_breakpoints",
                            "dapui_console",
                            "dapui_repl",
                            "dap-repl",
                        },
                        winbar = {},
                    },
                },
                sections = {
                    lualine_a = {
                        {
                            "mode",
                            -- mode 组件在非 codecompanion filetype 时显示
                            cond = function()
                                return vim.bo.filetype ~= "codecompanion"
                            end,
                        },
                    },
                    lualine_b = {
                        -- CodeCompanion adapter 和 model 显示
                        {
                            function()
                                if vim.bo.filetype ~= "codecompanion" then
                                    return ""
                                end

                                local bufnr = vim.api.nvim_get_current_buf()
                                local metadata = _G.codecompanion_chat_metadata
                                    and _G.codecompanion_chat_metadata[bufnr]

                                if not metadata or not metadata.adapter then
                                    return ""
                                end

                                local adapter_info = metadata.adapter.name or ""
                                if metadata.adapter.model then
                                    adapter_info = adapter_info .. " (" .. metadata.adapter.model .. ")"
                                end

                                return "🤖 " .. adapter_info
                            end,
                            cond = function()
                                return vim.bo.filetype == "codecompanion"
                            end,
                            color = { fg = "#7aa2f7" },
                        },
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
                        -- CodeCompanion 请求处理状态（Spinner 已移除）
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
                        -- CodeCompanion 元数据显示（右侧显示 tokens, cycles, tools）
                        {
                            function()
                                if vim.bo.filetype ~= "codecompanion" then
                                    return ""
                                end

                                local bufnr = vim.api.nvim_get_current_buf()
                                local metadata = _G.codecompanion_chat_metadata
                                    and _G.codecompanion_chat_metadata[bufnr]

                                if not metadata then
                                    return ""
                                end

                                local parts = {}

                                -- 只显示 tokens, cycles, tools（adapter 和 model 已移到左侧）

                                -- 显示 tokens
                                if metadata.tokens and metadata.tokens > 0 then
                                    table.insert(parts, "🪙 " .. metadata.tokens)
                                end

                                -- 显示 cycles
                                if metadata.cycles and metadata.cycles > 0 then
                                    table.insert(parts, "🔄 " .. metadata.cycles)
                                end

                                -- 显示 tools
                                if metadata.tools and metadata.tools > 0 then
                                    table.insert(parts, "🔧 " .. metadata.tools)
                                end

                                return table.concat(parts, " │ ")
                            end,
                            cond = function()
                                return vim.bo.filetype == "codecompanion"
                            end,
                            color = { fg = "#7aa2f7" },
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
                            -- 在 codecompanion filetype 时不显示
                            cond = function()
                                return vim.bo.filetype ~= "codecompanion"
                            end,
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
        event = "WinNew", -- 创建新窗口时加载
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
                    -- DAP UI windows
                    "dapui_scopes",
                    "dapui_stacks",
                    "dapui_watches",
                    "dapui_breakpoints",
                    "dapui_console",
                    "dapui_repl",
                },
            },
        },
    },
    {
        "folke/trouble.nvim",
        -- 命令和按键触发
        cmd = "Trouble",
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
        -- 命令触发
        cmd = "ZenMode",
        dependencies = {
            "folke/twilight.nvim",
            opts = {},
        },
        opts = {},
    },
    {
        "jeffkreeftmeijer/vim-numbertoggle",
        event = { "BufReadPost", "BufNewFile" },
    },
    {
        "nacro90/numb.nvim",
        event = "CmdlineEnter", -- 命令行输入时加载(用于跳转行号)
        opts = {
            number_only = true,
        },
    },
    {
        "folke/which-key.nvim",
        event = "VeryLazy", -- which-key 需要较早加载以捕获所有按键
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
                    memory = { icon = "󰍛 ", highlight = "CodeCompanionChatVariable" },
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
