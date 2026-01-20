return
--- @type LazySpec
{
    {
        "sudo-tee/opencode.nvim",
        dev = true,
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
            default_mode = "Sisyphus",
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
                input = {
                    text = {
                        wrap = true, -- Wraps text inside input window
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
                    warn = false, -- 包含警告
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
