return
--- @type LazySpec
{
    {
        "sudo-tee/opencode.nvim",
        event = "VeryLazy",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MeanderingProgrammer/render-markdown.nvim", -- 配置统一在 lua/plugins/ui.lua 中
            "saghen/blink.cmp", -- 补全支持
            "folke/snacks.nvim", -- 文件选择器
        },
        opts = {
            -- 只配置与默认不同的部分
            preferred_picker = "snacks", -- 使用 snacks 作为文件选择器
            preferred_completion = "blink", -- 使用 blink.cmp 作为补全引擎
            default_mode = "Sisyphus", -- 默认使用 sisyphus 模式（完整开发模式）
            -- 文件类型配置
            filetype = "opencode_output",
            -- 窗口配置
            win = {
                border = "rounded",
                width = 0.8,
                height = 0.8,
            },
            -- 渲染配置
            render = {
                enabled = true,
            },
            keymap = {
                input_window = {
                    -- 使用 Shift+Tab 切换 agent/mode
                    ["<S-Tab>"] = { "switch_mode", mode = { "n", "i" } },
                },
            },

            -- UI 优化配置
            ui = {
                position = "right", -- 窗口位置在右侧
                window_width = 0.40, -- 窗口宽度 40%
                zoom_width = 0.8, -- 缩放后宽度 80%
                input_height = 0.15, -- 输入窗口高度 15%
                display_model = true, -- 显示模型名称
                display_context_size = true, -- 显示上下文大小
                display_cost = true, -- 显示成本
                output = {
                    tools = {
                        show_output = true, -- 显示工具输出（diff、命令输出等）
                    },
                    rendering = {
                        markdown_debounce_ms = 250, -- markdown 渲染防抖 250ms
                    },
                },
                completion = {
                    file_sources = {
                        enabled = true,
                        preferred_cli_tool = "server", -- 使用 opencode cli 获取文件列表（跨平台支持）
                        max_files = 10,
                        max_display_length = 50,
                    },
                },
            },

            -- 上下文配置优化
            context = {
                enabled = true,
                cursor_data = {
                    enabled = false, -- 不包含光标位置（减少噪音）
                },
                diagnostics = {
                    info = false, -- 不包含 info 级别诊断
                    warn = true, -- 包含警告
                    error = true, -- 包含错误
                },
                current_file = {
                    enabled = true,
                },
                selection = {
                    enabled = true,
                },
            },
        },
    },
}
