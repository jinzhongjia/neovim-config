return
--- @type LazySpec
{
    {
        "coder/claudecode.nvim",
        dependencies = { "folke/snacks.nvim" },
        event = "VeryLazy",
        opts = {
            -- 基础配置
            terminal_cmd = nil, -- 使用默认的全局 claude 命令 (/usr/sbin/claude)
            log_level = "info", -- 日志级别: trace|debug|info|warn|error
            auto_start = true, -- 自动启动 WebSocket 服务器

            -- 选择跟踪配置
            track_selection = true, -- 实时追踪光标选择，Claude 能看到你正在查看的代码
            focus_after_send = true, -- 发送内容后自动聚焦 Claude 终端，方便继续对话

            -- 终端配置
            terminal = {
                provider = "snacks", -- 使用已有的 snacks.nvim 终端提供者
                git_repo_cwd = true, -- 在 git 仓库根目录工作，Claude 能看到完整项目结构

                -- 右侧分屏配置
                split_side = "right", -- 在右侧显示
                split_width_percentage = 0.35, -- 占屏幕宽度的 35%
            },

            -- Diff 配置 - 当 Claude 提议代码修改时的行为
            diff_opts = {
                auto_close_on_accept = true, -- 接受修改后自动关闭 diff 窗口
                vertical_split = true, -- 使用垂直分屏显示 diff，方便对比
                open_in_current_tab = true, -- 在当前标签页打开 diff
                keep_terminal_focus = true, -- 打开 diff 后保持焦点在 Claude 终端，方便继续对话
            },
        },

        keys = {
            -- AI/Claude 主菜单 (which-key 分组标识)
            { "<leader>a", nil, desc = "AI/Claude Code" },

            -- 窗口控制
            { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "切换 Claude", mode = { "n" } },
            { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "聚焦 Claude", mode = { "n" } },

            -- 会话管理
            { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "恢复会话", mode = { "n" } },
            { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "继续对话", mode = { "n" } },
            { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "选择模型", mode = { "n" } },

            -- 上下文管理
            { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "添加当前缓冲区", mode = { "n" } },
            { "<leader>as", "<cmd>ClaudeCodeSend<cr>", desc = "发送到 Claude", mode = "v" },
            {
                "<leader>as",
                "<cmd>ClaudeCodeTreeAdd<cr>",
                desc = "添加文件",
                ft = { "NvimTree" },
            },

            -- Diff 管理
            { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "接受修改", mode = { "n" } },
            { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "拒绝修改", mode = { "n" } },
        },
    },
}
