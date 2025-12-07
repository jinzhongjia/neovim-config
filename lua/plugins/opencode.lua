-- ========================
-- opencode.nvim - Neovim frontend for opencode AI coding agent
-- ========================
-- 文档：https://github.com/sudo-tee/opencode.nvim
-- 本地文档：docs/opencode-setup.md

return {
    "sudo-tee/opencode.nvim",
    event = "VeryLazy",
    dev = true,
    dependencies = {
        "nvim-lua/plenary.nvim",
        {
            "MeanderingProgrammer/render-markdown.nvim",
            opts = {
                anti_conceal = { enabled = false },
                file_types = { "markdown", "opencode_output" },
            },
            ft = { "markdown", "Avante", "copilot-chat", "opencode_output" },
        },
        "saghen/blink.cmp", -- 补全支持
        "folke/snacks.nvim", -- 文件选择器
    },
    opts = {
        -- 只配置与默认不同的部分
        preferred_picker = "snacks", -- 使用 snacks 作为文件选择器
        preferred_completion = "blink", -- 使用 blink.cmp 作为补全引擎
        default_mode = "build", -- 默认使用 build 模式（完整开发模式）

        -- 自定义快捷键配置
        keymap = {
            input_window = {
                -- 使用 Shift+Tab 切换 agent/mode
                ["<S-Tab>"] = { "switch_mode", mode = { "n", "i" } },
                -- 保留原来的 Tab 用于切换窗格
                ["<tab>"] = { "toggle_pane", mode = { "n", "i" } },
                -- 其他保持默认
                ["<cr>"] = { "submit_input_prompt", mode = { "n", "i" } },
                ["<esc>"] = { "close" },
                ["<C-c>"] = { "cancel" },
                ["@"] = { "mention", mode = "i" },
                ["/"] = { "slash_commands", mode = "i" },
                ["#"] = { "context_items", mode = "i" },
                ["<M-v>"] = { "paste_image", mode = "i" },
                ["<C-i>"] = { "focus_input", mode = { "n", "i" } },
                ["<up>"] = { "prev_prompt_history", mode = { "n", "i" } },
                ["<down>"] = { "next_prompt_history", mode = { "n", "i" } },
            },
            output_window = {
                ["<tab>"] = { "toggle_pane", mode = { "n", "i" } },
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

        -- 调试配置
        debug = {
            enabled = false, -- 生产环境关闭调试
        },
    },

    -- 快捷键定义（可选，使用默认快捷键也很好用）
    keys = {
        -- 基础操作
        { "<leader>og", "<cmd>Opencode<cr>", desc = "打开/关闭 Opencode" },
        { "<leader>oi", "<cmd>Opencode open input<cr>", desc = "打开输入窗口" },
        { "<leader>oI", "<cmd>Opencode open input_new_session<cr>", desc = "新会话并打开输入" },
        { "<leader>oo", "<cmd>Opencode open output<cr>", desc = "打开输出窗口" },
        { "<leader>ot", "<cmd>Opencode toggle focus<cr>", desc = "切换焦点" },
        { "<leader>oq", "<cmd>Opencode close<cr>", desc = "关闭窗口" },

        -- 会话管理
        { "<leader>os", "<cmd>Opencode session select<cr>", desc = "选择会话" },
        { "<leader>oS", "<cmd>Opencode session select_child<cr>", desc = "选择子会话" },
        { "<leader>oR", "<cmd>Opencode session rename<cr>", desc = "重命名会话" },
        { "<leader>oT", "<cmd>Opencode timeline<cr>", desc = "显示时间线" },

        -- Diff 操作
        { "<leader>od", "<cmd>Opencode diff open<cr>", desc = "打开 diff 视图" },
        { "<leader>o]", "<cmd>Opencode diff next<cr>", desc = "下一个 diff" },
        { "<leader>o[", "<cmd>Opencode diff prev<cr>", desc = "上一个 diff" },
        { "<leader>oc", "<cmd>Opencode diff close<cr>", desc = "关闭 diff" },

        -- 撤销操作
        { "<leader>ora", "<cmd>Opencode revert all prompt<cr>", desc = "撤销最后提示的所有更改" },
        { "<leader>ort", "<cmd>Opencode revert this prompt<cr>", desc = "撤销当前文件的最后更改" },
        { "<leader>orA", "<cmd>Opencode revert all session<cr>", desc = "撤销会话的所有更改" },
        { "<leader>orT", "<cmd>Opencode revert this session<cr>", desc = "撤销当前文件的会话更改" },

        -- 其他操作
        { "<leader>op", "<cmd>Opencode configure provider<cr>", desc = "配置提供商/模型" },
        { "<leader>oz", "<cmd>Opencode toggle zoom<cr>", desc = "缩放窗口" },
        { "<leader>ov", "<cmd>Opencode paste image<cr>", desc = "粘贴图片" },
        { "<leader>ox", "<cmd>Opencode swap position<cr>", desc = "交换窗口位置" },

        -- 权限操作
        { "<leader>opa", "<cmd>Opencode permission accept<cr>", desc = "接受权限请求" },
        { "<leader>opA", "<cmd>Opencode permission accept_all<cr>", desc = "接受所有权限请求" },
        { "<leader>opd", "<cmd>Opencode permission deny<cr>", desc = "拒绝权限请求" },
    },
}
