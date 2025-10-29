-- codecompanion yolo mode
vim.g.codecompanion_yolo_mode = true

-- ========================
-- 通用常量配置
-- ========================
local DEFAULT_COPILOT_FREE_MODEL = "gpt-4.1"
local DEFAULT_COPILOT_MODEL = "claude-sonnet-4"

local DEFAULT_CLAUDE_AUTH_MODEL = "claude-opus-4-1"
local DEFAULT_CLAUDE_AUTH_MIDDLE_MODEL = "claude-sonnet-4-5"
local DEFAULT_CLAUDE_AUTH_FAST_MODEL = "claude-haiku-4-5"

-- ========================
-- 适配器使用配置（统一管理）
-- ========================
local adapter_usage = {
    -- 主要功能
    chat = "anthropic_oauth", -- 聊天功能默认适配器
    inline = "inline_adapter", -- 内联编辑适配器

    -- 扩展功能
    history_title = "anthropic_oauth", -- 历史记录标题生成
    git_commit = "anthropic_oauth", -- Git commit 消息生成
    translator = "anthropic_oauth", -- 翻译工具
}

-- ========================
-- 模型使用配置（统一管理）
-- ========================
local model_usage = {
    -- 扩展功能使用的模型
    history_title = DEFAULT_CLAUDE_AUTH_FAST_MODEL, -- 历史记录标题生成
    git_commit = DEFAULT_CLAUDE_AUTH_FAST_MODEL, -- Git commit 消息生成
    translator = DEFAULT_CLAUDE_AUTH_FAST_MODEL, -- 翻译工具
}

-- ========================
-- 环境变量配置
-- ========================
local env = {
    API_KEY = os.getenv("AI_KEY"),
    OPENROUTER_KEY = os.getenv("OPENROUTER_KEY"),
    TAVILY_KEY = os.getenv("TAVILY_KEY"),
    LLM_ROUTER_URL = os.getenv("LLM_ROUTER_URL"),
    MONICA_KEY = os.getenv("MONICA_KEY"),
}

local function get_adapters()
    local default_adpters = { http = {}, acp = {} }

    -- Copilot 适配器
    default_adpters.http.copilot = function()
        return require("codecompanion.adapters").extend("copilot", {
            schema = { model = { default = DEFAULT_COPILOT_MODEL } },
        })
    end

    default_adpters.http.copilot_4_1 = function()
        return require("codecompanion.adapters").extend("copilot", {
            schema = { model = { default = DEFAULT_COPILOT_FREE_MODEL } },
        })
    end

    -- BigModel 适配器
    if env.API_KEY and env.API_KEY ~= "" then
        default_adpters.http.bigmodel = function()
            return require("codecompanion.adapters").extend("openai_compatible", {
                name = "bigmodel",
                formatted_name = "BigModel",
                env = {
                    url = "https://open.bigmodel.cn/api/paas/",
                    api_key = env.API_KEY,
                    chat_url = "/v4/chat/completions",
                },
                schema = { model = { default = "glm-4.5" } },
            })
        end
    end

    -- Monica 适配器
    if env.MONICA_KEY and env.MONICA_KEY ~= "" then
        default_adpters.http.monica = function()
            return require("codecompanion.adapters").extend("openai_compatible", {
                name = "monica",
                formatted_name = "Monica",
                env = {
                    url = "https://openapi.monica.im",
                    api_key = env.MONICA_KEY,
                    chat_url = "/v1/chat/completions",
                },
                schema = {
                    model = {
                        ---@type string|fun(): string
                        default = "gpt-5",
                        choices = {
                            ["gpt-5"] = { opts = { has_vision = true, can_reason = false, stream = false } },
                            ["claude-4-sonnet"] = {
                                opts = { has_vision = true, can_reason = false, stream = false },
                            },
                            ["gemini-2.5-pro"] = { opts = { has_vision = true, can_reason = false, stream = false } },
                        },
                    },
                },
            })
        end
    end

    -- OpenRouter 适配器
    if env.OPENROUTER_KEY and env.OPENROUTER_KEY ~= "" then
        default_adpters.http.openrouter = function()
            return require("codecompanion.adapters").extend("openai_compatible", {
                name = "openrouter",
                formatted_name = "OpenRouter",
                env = {
                    url = "https://openrouter.ai/api",
                    api_key = env.OPENROUTER_KEY,
                    chat_url = "/v1/chat/completions",
                },
                schema = { model = { default = "openrouter/horizon-alpha" } },
            })
        end
    end

    -- Tavily 适配器（用于网页搜索）
    if env.TAVILY_KEY and env.TAVILY_KEY ~= "" then
        default_adpters.http.tavily = function()
            return require("codecompanion.adapters").extend("tavily", {
                url = "https://searx.nvimer.org/search",
                env = { api_key = env.TAVILY_KEY },
            })
        end
    end

    -- LLM Router 适配器
    if env.LLM_ROUTER_URL and env.LLM_ROUTER_URL ~= "" then
        default_adpters.http.llm_router = function()
            return require("codecompanion.adapters").extend("openai_compatible", {
                name = "llm_router",
                formatted_name = "LLM Router",
                env = { url = env.LLM_ROUTER_URL, api_key = "*******" },
                schema = { model = { default = "claude-4-opus" } },
            })
        end
    end

    local claude_code = require("extension.anthropic-oauth")

    -- Anthropic OAuth 适配器
    default_adpters.http.anthropic_oauth = claude_code

    -- Anthropic OAuth - Inline 适配器
    default_adpters.http.inline_adapter = function()
        return require("codecompanion.adapters").extend("anthropic_oauth", {
            name = "inline_adapter",
            formatted_name = "Anthropic OAuth (Inline)",
            schema = { model = { default = DEFAULT_CLAUDE_AUTH_MIDDLE_MODEL } },
        })
    end

    default_adpters.acp.claude_code = function()
        return require("codecompanion.adapters").extend("claude_code", {
            env = {
                ANTHROPIC_API_KEY = function()
                    return claude_code.get_api_key()
                end,
            },
        })
    end

    -- 适配器全局选项
    default_adpters.http.opts = { show_defaults = false, show_model_choices = true }

    return default_adpters
end

-- ========================
-- 默认适配器选择
-- ========================
local get_default_adapter = function()
    return adapter_usage.chat
end

-- ========================
-- Slash Commands 通用配置
-- ========================
local slash_command_defaults = {
    contains_code = true,
    provider = "snacks",
}

-- ========================
-- 插件配置
-- ========================
return {
    -- ========== CodeCompanion 主插件 ==========
    {
        "olimorris/codecompanion.nvim",
        event = "VeryLazy",
        dev = true,
        dependencies = {
            -- 核心依赖
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nvim-telescope/telescope.nvim",
            "j-hui/fidget.nvim",
            "lalitmee/codecompanion-spinners.nvim", -- 添加 spinner 扩展

            -- AI 相关
            "zbirenbaum/copilot.lua",

            -- 扩展插件
            "Davidyz/VectorCode",
            "ravitemer/mcphub.nvim",
            "ravitemer/codecompanion-history.nvim",
            { "jinzhongjia/codecompanion-gitcommit.nvim", dev = true },
        },
        opts = function()
            return {
                -- 基础选项
                opts = {
                    language = "Chinese",
                    log_level = "INFO", -- TRACE|DEBUG|ERROR|INFO
                },

                -- 适配器配置
                adapters = get_adapters(),

                -- 显示配置
                display = {
                    action_palette = { provider = "snacks" },
                    chat = {
                        intro_message = "欢迎使用 CodeCompanion ✨! 按下 ? 查看快捷键",
                        window = { opts = { relativenumber = false, number = false, winbar = "" } },
                        show_token_count = false,
                        fold_context = true,
                    },
                    diff = {
                        provider = "inline", -- default|mini_diff|inline
                    },
                },
                memory = {
                    opts = {
                        chat = {
                            enabled = true,
                        },
                    },
                },

                -- 策略配置
                strategies = {
                    chat = {
                        adapter = get_default_adapter(),
                        keymaps = {
                            send = { modes = { n = "<CR>" } },
                            close = { modes = { n = "<leader>c", i = "<C-c>" } },
                        },
                        roles = {
                            llm = function(adapter)
                                return "CodeCompanion (" .. adapter.formatted_name .. ")"
                            end,
                            user = "我",
                        },
                        -- Slash Commands 配置
                        slash_commands = {
                            ["buffer"] = { opts = slash_command_defaults },
                            ["file"] = { opts = slash_command_defaults },
                            ["symbols"] = { opts = slash_command_defaults },
                            ["help"] = { opts = slash_command_defaults },
                            ["workspace"] = { opts = slash_command_defaults },
                            ["terminal"] = { opts = slash_command_defaults },
                        },
                        -- 工具配置
                        tools = {
                            opts = {
                                default_tools = {
                                    "full_stack_dev",
                                    "search_web",
                                    "fetch_webpage",
                                },
                            },
                        },
                    },
                    inline = { adapter = adapter_usage.inline },
                },

                -- 扩展配置
                extensions = {
                    -- VectorCode 扩展
                    vectorcode = {
                        opts = {
                            tool_group = { enabled = true, extras = {}, collapse = true },
                            tool_opts = {
                                ["*"] = {},
                                ls = {},
                                vectorise = {},
                                query = {
                                    max_num = { chunk = -1, document = -1 },
                                    default_num = { chunk = 50, document = 10 },
                                    include_stderr = false,
                                    use_lsp = false,
                                    no_duplicate = true,
                                    chunk_mode = true,
                                    summarise = { enabled = false, adapter = nil, query_augmented = true },
                                },
                                files_ls = {},
                                files_rm = {},
                            },
                        },
                    },

                    -- MCPHub 扩展
                    mcphub = {
                        callback = "mcphub.extensions.codecompanion",
                        opts = {
                            make_tools = true,
                            show_server_tools_in_chat = true,
                            add_mcp_prefix_to_tool_names = true,
                            show_result_in_chat = true,
                            format_tool = nil,
                            make_vars = true,
                            make_slash_commands = true,
                        },
                    },

                    -- 历史记录扩展
                    history = {
                        enabled = true,
                        opts = {
                            keymap = "gh",
                            auto_generate_title = true,
                            continue_last_chat = false,
                            delete_on_clearing_chat = false,
                            picker = "snacks",
                            enable_logging = false,
                            dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
                            title_generation_opts = {
                                adapter = adapter_usage.history_title,
                                model = model_usage.history_title,
                            },
                        },
                    },

                    -- Git Commit 扩展
                    gitcommit = {
                        enabled = true,
                        opts = {
                            add_slash_command = true,
                            adapter = adapter_usage.git_commit,
                            model = model_usage.git_commit,
                            languages = { "English", "Chinese" },
                            exclude_files = {
                                "*.pb.go",
                                "*.generated.*",
                                "vendor/*",
                                "*.lock",
                                "*gen.go",
                            },
                            buffer = {
                                enabled = true,
                                keymap = "<leader>gc",
                                auto_generate = true,
                            },
                        },
                    },
                    -- Spinner 扩展（使用 fidget 样式）
                    spinner = {
                        enabled = true,
                        opts = {
                            style = "fidget", -- 使用 fidget.nvim 显示进度
                            -- Use default English messages from the spinner extension
                        },
                    },
                },
            }
        end,
        keys = {
            { "<leader>cc", ":CodeCompanionChat Toggle<CR>", desc = "Toggle CodeCompanionChat" },
            { "<leader>cc", ":CodeCompanionChat Add<CR>", mode = "v", desc = "Toggle CodeCompanionChat" },
        },
    },

    -- ========== VectorCode ==========
    {
        "Davidyz/VectorCode",
        dependencies = { "nvim-lua/plenary.nvim" },
        event = "VeryLazy",
        cmd = "VectorCode",
        opts = {
            on_setup = {
                update = false,
                lsp = false,
            },
        },
    },

    -- ========== Copilot ==========
    {
        "zbirenbaum/copilot.lua",
        event = "VeryLazy",
        opts = {
            copilot_model = "gpt-41-copilot",
            suggestion = {
                enabled = true,
                auto_trigger = true,
            },
            panel = { enabled = false },
            filetypes = {
                ["*"] = false,
                lua = true,
                go = true,
                zig = true,
                typescript = true,
                javascript = true,
                vue = true,
                c = true,
                cpp = true,
                proto = true,
                markdown = true,
                yaml = true,
            },
        },
    },

    -- ========== MCPHub ==========
    {
        "ravitemer/mcphub.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        cmd = "MCPHub",
        build = "bundled_build.lua",
        config = function()
            require("mcphub").setup({
                config = vim.fn.expand(vim.fn.stdpath("config") .. "/mcphub_servers.json"),
                auto_approve = true,
                use_bundled_binary = true,
            })
        end,
    },

    -- ========== ClaudeCode ==========
    {
        "coder/claudecode.nvim",
        dependencies = { "folke/snacks.nvim" },
        config = true,
        dev = true,
        keys = {
            { "<leader>a", nil, desc = "AI/Claude Code" },
            { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
            { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
            { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
            { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
            { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
            { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
            { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
            {
                "<leader>as",
                "<cmd>ClaudeCodeTreeAdd<cr>",
                desc = "Add file",
                ft = { "NvimTree", "neo-tree", "oil", "minifiles" },
            },
            { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
            { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
        },
    },

    -- ========== CodeCompanion Tools ==========
    {
        "jinzhongjia/codecompanion-tools.nvim",
        dev = true,
        event = "VeryLazy",
        opts = {
            translator = {
                adapter = adapter_usage.translator,
                model = model_usage.translator,
                default_target_lang = "zh",
                debug = {
                    enabled = false,
                    log_level = "INFO",
                },
                output = {
                    show_original = true,
                    notification_timeout = 5000,
                    copy_to_clipboard = false,
                },
            },
        },
    },

    -- ========== Sidekick ==========
    {
        "folke/sidekick.nvim",
        event = "VeryLazy",
        dependencies = {
            "zbirenbaum/copilot.lua", -- Copilot LSP server
            "neovim/nvim-lspconfig",
            "folke/snacks.nvim", -- for picker
        },
        init = function()
            -- 全局变量，控制是否启用 NES 功能
            vim.g.sidekick_nes = true
        end,
        config = function(_, opts)
            require("sidekick").setup(opts)

            -- 监听 blink.cmp 菜单关闭事件，自动清除 NES
            vim.api.nvim_create_autocmd("User", {
                pattern = "BlinkCmpMenuClose",
                callback = function()
                    require("sidekick").clear()
                end,
                desc = "clear sidekick NES when blink cmp menu closes",
            })
        end,
        opts = {
            jump = {
                jumplist = true, -- 添加跳转到 jumplist
            },
            nes = {
                enabled = function(buf)
                    return vim.g.sidekick_nes ~= false and vim.b.sidekick_nes ~= false
                end,
                -- trigger = {
                --     -- events that trigger sidekick next edit suggestions
                --     events = { "InsertLeave", "TextChanged", "User SidekickNesDone", "CursorHold" },
                -- },
                diff = {
                    inline = "words",
                },
            },
            cli = {
                watch = true, -- 自动监听文件变化
                win = {
                    layout = "right", -- 右侧布局
                    split = {
                        width = 90, -- 增加宽度以适应更多内容
                        height = 25,
                    },
                    -- 窗口样式配置
                    border = "rounded",
                    title = " AI Assistant ",
                    title_pos = "center",
                },
                mux = {
                    backend = "zellij",
                    enabled = false, -- 根据需要启用 tmux/zellij
                },
                -- AI CLI 工具配置
                tools = {
                    -- Claude Code - Anthropic 官方 CLI
                    claude = {
                        cmd = { "claude" },
                        url = "https://github.com/anthropics/claude-code",
                        description = "Claude Code - 强大的 AI 编程助手",
                    },
                    -- Claude Code 快速模式
                    claude_quick = {
                        cmd = { "claude", "--model", "claude-sonnet-4-5" },
                        url = "https://github.com/anthropics/claude-code",
                        description = "Claude Code (快速模式)",
                    },
                    -- Aider - AI 结对编程工具
                    aider = {
                        cmd = { "aider" },
                        url = "https://github.com/paul-gauthier/aider",
                        description = "Aider - AI 结对编程助手",
                    },
                    aider_claude = {
                        cmd = { "aider", "--model", "claude-sonnet-4-5" },
                        url = "https://github.com/paul-gauthier/aider",
                        description = "Aider (使用 Claude)",
                    },
                    -- GitHub Copilot CLI
                    copilot = {
                        cmd = { "copilot", "--banner" },
                        url = "https://github.com/github/copilot-cli",
                        description = "GitHub Copilot CLI",
                    },
                    -- Gemini CLI
                    gemini = {
                        cmd = { "gemini" },
                        url = "https://github.com/google-gemini/gemini-cli",
                        description = "Google Gemini CLI",
                    },
                    -- Grok CLI
                    grok = {
                        cmd = { "grok" },
                        url = "https://github.com/superagent-ai/grok-cli",
                        description = "Grok AI CLI",
                    },
                    -- OpenAI Codex
                    codex = {
                        cmd = { "codex", "--search" },
                        url = "https://github.com/openai/codex",
                        description = "OpenAI Codex",
                    },
                    -- Cursor CLI (如果有)
                    cursor = {
                        cmd = { "cursor-cli" },
                        url = "https://cursor.sh",
                        description = "Cursor AI Editor CLI",
                    },
                    -- ChatGPT CLI
                    chatgpt = {
                        cmd = { "chatgpt" },
                        url = "https://github.com/j178/chatgpt",
                        description = "ChatGPT CLI",
                    },
                },
                -- 提示词配置
                prompts = {
                    -- 代码理解
                    explain = "请详细解释这段代码的功能、逻辑和实现方式",
                    understand = "帮我理解这段代码在做什么，以及为什么这样实现",
                    architecture = "分析这个代码的架构设计和模式",

                    -- 代码改进
                    optimize = "分析并优化这段代码的性能、可读性和可维护性",
                    refactor = "重构这段代码，使其更加清晰、简洁和符合最佳实践",
                    simplify = "简化这段代码，去除不必要的复杂性",
                    modernize = "使用最新的语言特性和最佳实践来现代化这段代码",

                    -- 问题修复
                    fix = {
                        msg = "修复这段代码中的所有问题和错误",
                        diagnostics = true,
                    },
                    debug = {
                        msg = "帮我调试这段代码，找出潜在的问题",
                        diagnostics = true,
                    },
                    diagnostics = {
                        msg = "解释这个文件中的诊断信息并提供修复建议",
                        diagnostics = true,
                    },

                    -- 代码质量
                    review = {
                        msg = "全面审查这段代码，包括安全性、性能、可读性等方面",
                        diagnostics = true,
                    },
                    security = "检查这段代码的安全漏洞和潜在风险",
                    performance = "分析这段代码的性能瓶颈并提出优化建议",

                    -- 测试相关
                    tests = "为这段代码编写全面的单元测试",
                    test_cases = "生成这个功能的测试用例，包括边界情况",
                    coverage = "分析测试覆盖率并补充缺失的测试",

                    -- 文档相关
                    docs = "为这段代码编写清晰详细的文档注释",
                    readme = "为这个模块生成 README 文档",
                    api_doc = "生成这个 API 的使用文档和示例",

                    -- 代码生成
                    implement = "根据需求实现这个功能",
                    complete = "补全这段未完成的代码",
                    scaffold = "为这个功能创建基础框架代码",

                    -- 转换和迁移
                    convert = "将这段代码转换为另一种语言或框架",
                    migrate = "帮我将这段代码迁移到新版本",
                    translate = "将代码中的注释和文档翻译为英文",

                    -- 交互式
                    chat = "我想和你讨论这段代码",
                    question = "我有关于这段代码的问题",
                },
            },
            copilot = {
                status = {
                    enabled = true, -- 启用状态跟踪
                },
            },
            debug = false,
        },
        keys = {
            -- ===== Next Edit Suggestions 快捷键 =====
            {
                "<tab>",
                function()
                    -- 如果有下一个编辑，跳转到它；如果已经是最后一个，则应用所有编辑
                    if require("sidekick").nes_jump_or_apply() then
                        return -- 成功跳转或应用
                    end

                    -- 回退到普通 Tab 行为
                    return "<Tab>"
                end,
                expr = true,
                desc = "Sidekick: Jump to/Apply next edit",
                mode = "n", -- 仅支持 normal 模式，insert 模式由 blink.cmp 处理
            },
            -- 手动控制 NES
            {
                "<leader>su",
                function()
                    require("sidekick.nes").update()
                end,
                desc = "Sidekick: Update suggestions",
            },
            {
                "<leader>sj",
                function()
                    require("sidekick.nes").jump()
                end,
                desc = "Sidekick: Jump to edit",
            },
            {
                "<leader>sa",
                function()
                    require("sidekick.nes").apply()
                end,
                desc = "Sidekick: Apply edit",
            },
            {
                "<leader>sx",
                function()
                    require("sidekick").clear()
                end,
                desc = "Sidekick: Clear suggestions",
            },

            -- ===== AI CLI 工具快捷键 =====
            -- 快速选择 AI 工具
            {
                "<leader>sc",
                function()
                    require("sidekick.cli").select()
                end,
                desc = "Sidekick: Select AI tool",
                mode = { "n", "v" },
            },
            -- 快速选择提示词
            {
                "<leader>sp",
                function()
                    require("sidekick.cli").prompt()
                end,
                desc = "Sidekick: Select prompt",
                mode = { "n", "v" },
            },
            -- 切换 AI CLI 窗口
            {
                "<leader>st",
                function()
                    require("sidekick.cli").toggle()
                end,
                desc = "Sidekick: Toggle CLI window",
            },
            -- 关闭 AI CLI
            {
                "<leader>sq",
                function()
                    require("sidekick.cli").close()
                end,
                desc = "Sidekick: Close CLI",
            },
            -- 发送选区到 AI
            {
                "<leader>ss",
                function()
                    require("sidekick.cli").send({ msg = "{selection}" })
                end,
                desc = "Sidekick: Send selection",
                mode = { "v" },
            },
            -- 发送当前文件到 AI
            {
                "<leader>sF",
                function()
                    require("sidekick.cli").send({ msg = "{file}" })
                end,
                desc = "Sidekick: Send file",
                mode = { "n" },
            },
            -- 发送当前行到 AI
            {
                "<leader>sl",
                function()
                    require("sidekick.cli").send({ msg = "{this}" })
                end,
                desc = "Sidekick: Send current line",
                mode = { "n" },
            },

            -- ===== 特定 AI 工具快捷键 =====
            -- Claude Code
            {
                "<leader>sC",
                function()
                    require("sidekick.cli").toggle({ name = "claude", focus = true })
                end,
                desc = "Sidekick: Open Claude Code",
                mode = { "n", "v" },
            },
            -- Aider
            {
                "<leader>sA",
                function()
                    require("sidekick.cli").toggle({ name = "aider", focus = true })
                end,
                desc = "Sidekick: Open Aider",
                mode = { "n", "v" },
            },
            -- GitHub Copilot
            {
                "<leader>sP",
                function()
                    require("sidekick.cli").toggle({ name = "copilot", focus = true })
                end,
                desc = "Sidekick: Open Copilot CLI",
                mode = { "n", "v" },
            },
            -- Gemini
            {
                "<leader>sG",
                function()
                    require("sidekick.cli").toggle({ name = "gemini", focus = true })
                end,
                desc = "Sidekick: Open Gemini CLI",
                mode = { "n", "v" },
            },
        },
    },
}
