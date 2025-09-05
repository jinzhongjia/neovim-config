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
            -- 创建 CodeCompanion Spinner 组件
            local codecompanion_spinner = require("lualine.component"):extend()

            -- 预定义的 spinner 样式
            local spinner_styles = {
                dots = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
                dots2 = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" },
                line = { "-", "\\", "|", "/" },
                star = { "✶", "✸", "✹", "✺", "✹", "✸" },
                bounce = { "⠁", "⠂", "⠄", "⡀", "⢀", "⠠", "⠐", "⠈" },
                box = { "▖", "▘", "▝", "▗" },
                arc = { "◜", "◠", "◝", "◞", "◡", "◟" },
                circle = { "◐", "◓", "◑", "◒" },
                square = { "◰", "◳", "◲", "◱" },
                triangle = { "◢", "◣", "◤", "◥" },
            }

            -- 全局状态管理
            local spinner_state = {
                is_processing = false,
                current_index = 1,
                timer = nil,
                autocmd_created = false,
                last_status = "finished", -- "started", "finished", "error"
                instances = {}, -- 跟踪所有实例
                update_scheduled = false,
            }

            -- 停止定时器
            local function stop_timer()
                if spinner_state.timer then
                    spinner_state.timer:stop()
                    spinner_state.timer:close()
                    spinner_state.timer = nil
                end
            end

            -- 防抖的状态栏刷新
            local function debounced_redraw()
                if not spinner_state.update_scheduled then
                    spinner_state.update_scheduled = true
                    vim.defer_fn(function()
                        vim.cmd("redrawstatus!")
                        spinner_state.update_scheduled = false
                    end, 10) -- 10ms 防抖延迟
                end
            end

            -- 异步启动定时器
            local function start_timer(interval, symbols_count)
                stop_timer()

                spinner_state.timer = vim.loop.new_timer()
                if spinner_state.timer then
                    local callback = function()
                        if spinner_state.is_processing then
                            -- 使用原子操作更新索引
                            spinner_state.current_index = (spinner_state.current_index % symbols_count) + 1
                            debounced_redraw()
                        else
                            vim.schedule(function()
                                stop_timer()
                            end)
                        end
                    end

                    -- 使用 vim.schedule_wrap 确保在主线程执行
                    spinner_state.timer:start(0, interval, vim.schedule_wrap(callback))
                end
            end

            -- Initializer
            function codecompanion_spinner:init(options)
                codecompanion_spinner.super.init(self, options)

                -- 配置选项
                self.style = options.style or "dots"
                self.interval = options.interval or 80 -- 动画更新间隔（毫秒）
                self.show_when_done = options.show_when_done or false
                self.done_icon = options.done_icon or "✓"
                self.error_icon = options.error_icon or "✗"
                self.fade_out = options.fade_out or false
                self.fade_delay = options.fade_delay or 2000 -- 完成后淡出延迟（毫秒）
                self.smooth = options.smooth ~= false -- 平滑动画，默认开启

                -- 允许自定义符号
                if options.symbols then
                    self.symbols = options.symbols
                else
                    self.symbols = spinner_styles[self.style] or spinner_styles.dots
                end

                -- 注册实例
                table.insert(spinner_state.instances, self)

                -- 只创建一次自动命令，避免重复
                if not spinner_state.autocmd_created then
                    local group = vim.api.nvim_create_augroup("CodeCompanionHooks", { clear = true })

                    vim.api.nvim_create_autocmd({ "User" }, {
                        pattern = "CodeCompanionRequest*",
                        group = group,
                        callback = function(request)
                            -- 获取第一个实例的配置
                            local instance = spinner_state.instances[1]
                            if not instance then
                                return
                            end

                            if request.match == "CodeCompanionRequestStarted" then
                                vim.schedule(function()
                                    spinner_state.is_processing = true
                                    spinner_state.last_status = "started"
                                    spinner_state.current_index = 1
                                    start_timer(instance.interval, #instance.symbols)
                                end)
                            elseif request.match == "CodeCompanionRequestFinished" then
                                vim.schedule(function()
                                    spinner_state.is_processing = false

                                    -- 根据请求结果设置状态
                                    if request.data and request.data.status == "error" then
                                        spinner_state.last_status = "error"
                                    else
                                        spinner_state.last_status = "finished"
                                    end

                                    -- 如果设置了淡出，异步延迟清除状态
                                    if instance.fade_out and instance.show_when_done then
                                        vim.defer_fn(function()
                                            spinner_state.last_status = nil
                                            debounced_redraw()
                                        end, instance.fade_delay)
                                    end

                                    debounced_redraw()
                                end)
                            end
                        end,
                    })

                    -- 清理资源
                    vim.api.nvim_create_autocmd({ "VimLeavePre", "VimSuspend" }, {
                        group = group,
                        callback = function()
                            stop_timer()
                            spinner_state.instances = {}
                        end,
                    })

                    spinner_state.autocmd_created = true
                end
            end

            -- Function that runs every time statusline is updated
            function codecompanion_spinner:update_status()
                if spinner_state.is_processing then
                    -- 使用缓存的索引值，避免频繁计算
                    local idx = ((spinner_state.current_index - 1) % #self.symbols) + 1
                    return self.symbols[idx]
                elseif self.show_when_done and spinner_state.last_status then
                    -- 显示完成或错误状态
                    if spinner_state.last_status == "error" then
                        return self.error_icon
                    elseif spinner_state.last_status == "finished" then
                        return self.done_icon
                    end
                end
                return nil
            end

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
                        -- CodeCompanion 请求处理状态
                        {
                            codecompanion_spinner,
                            color = { fg = "#7aa2f7", gui = "bold" },
                            separator = { right = "" },
                            padding = { left = 1, right = 0 },
                            cond = function()
                                return vim.bo.filetype == "codecompanion"
                            end,
                        },
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
