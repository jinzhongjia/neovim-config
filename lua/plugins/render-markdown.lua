return
--- @type LazySpec
{
    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown", "codecompanion", "opencode_output" },
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
        opts = {
            -- 启用所有需要的 filetype（需与 ft 保持一致）
            file_types = { "markdown", "codecompanion", "opencode_output" },
            -- 启用 anti-conceal：光标所在行显示原始 markdown 语法
            anti_conceal = {
                enabled = true,
                -- 光标上下各显示 0 行的原始语法（仅当前行）
                above = 0,
                below = 0,
            },
            -- 启用 LSP completions 支持（用于 checkbox 和 callouts 补全）
            completions = {
                lsp = { enabled = true },
            },
            -- Checkbox 自定义样式
            checkbox = {
                unchecked = { icon = "✘ " },
                checked = { icon = "✔ " },
                custom = { todo = { rendered = "◯ " } },
            },
            -- HTML 标签渲染（保留原有配置）
            html = {
                enabled = true,
                tag = {
                    buf = { icon = "󱔗 ", highlight = "CodeCompanionChatVariable" },
                    file = { icon = "󰈮 ", highlight = "CodeCompanionChatVariable" },
                    help = { icon = "󰱼 ", highlight = "CodeCompanionChatVariable" },
                    image = { icon = " ", highlight = "CodeCompanionChatVariable" },
                    symbols = { icon = " ", highlight = "CodeCompanionChatVariable" },

                    url = { icon = "󰖟 ", highlight = "CodeCompanionChatVariable" },
                    var = { icon = " ", highlight = "CodeCompanionChatVariable" },
                    tool = { icon = " ", highlight = "CodeCompanionChatTool" },
                    user = { icon = " ", highlight = "CodeCompanionChatTool" },
                    group = { icon = " ", highlight = "CodeCompanionChatToolGroup" },
                    memory = { icon = "󰍛 ", highlight = "CodeCompanionChatVariable" },
                    rules = { icon = "󰺾 ", highlight = "CodeCompanionChatVariable" },
                },
            },
            -- 针对特殊 buffer 类型的优化
            overrides = {
                buftype = {
                    -- 为 nofile 类型的 buffer（如 codecompanion chat）优化
                    nofile = {
                        render_modes = true, -- 在所有模式下渲染
                        sign = { enabled = false }, -- 禁用 sign column（chat buffer 不需要）
                        padding = { highlight = "NormalFloat" }, -- 使用浮动窗口背景色
                    },
                },
            },
        },
    },
}
