-- codecompanion yolo mode
vim.g.codecompanion_yolo_mode = true

-- ========================
-- 通用常量配置
-- ========================
local DEFAULT_COPILOT_FREE_MODEL = "gpt-4.1"
local DEFAULT_COPILOT_MODEL = "claude-sonnet-4"

local DEFAULT_CLAUDE_AUTH_MODEL = "claude-opus-4-1"
local DEFAULT_CLAUDE_AUTH_MIDDLE_MODEL = "claude-opus-4-5"
local DEFAULT_CLAUDE_AUTH_FAST_MODEL = "claude-haiku-4-5"
local DEFAULT_FAST_GEMINI_MODEL = "gemini-3-flash"

-- ========================
-- 适配器使用配置（统一管理）
-- ========================
local adapter_usage = {
    -- 主要功能
    chat = "anthropic_oauth", -- 聊天功能默认适配器
    inline = "inline_adapter", -- 内联编辑适配器

    -- 扩展功能
    history_title = "copilot_4_1", -- 历史记录标题生成
    git_commit = "anthropic_oauth", -- Git commit 消息生成
    translator = "anthropic_oauth", -- 翻译工具
}

-- ========================
-- 模型使用配置（统一管理）
-- ========================
local model_usage = {
    -- 扩展功能使用的模型
    history_title = DEFAULT_COPILOT_FREE_MODEL, -- 历史记录标题生成
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

    -- Tavily 适配器（用于网页搜索）
    if env.TAVILY_KEY and env.TAVILY_KEY ~= "" then
        default_adpters.http.tavily = function()
            return require("codecompanion.adapters").extend("tavily", {
                url = "https://searx.nvimer.org/search",
                env = { api_key = env.TAVILY_KEY },
            })
        end
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
            "j-hui/fidget.nvim",
            "lalitmee/codecompanion-spinners.nvim", -- 添加 spinner 扩展

            -- AI 相关
            "zbirenbaum/copilot.lua",
            {
                "ravitemer/mcphub.nvim",
            },
            {
                "ravitemer/codecompanion-history.nvim",
            },
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
                    action_palette = {
                        provider = "snacks",
                        opts = {
                            title = "CodeCompanion 操作面板", -- 自定义标题
                        },
                    },
                    chat = {
                        intro_message = "欢迎使用 CodeCompanion ✨! 按下 ? 查看快捷键",
                        window = {
                            layout = "vertical", -- 明确指定布局
                            width = 0.45, -- 窗口宽度
                            opts = {
                                relativenumber = false,
                                number = false,
                                signcolumn = "no", -- 隐藏左侧标记列
                                winbar = "",
                                wrap = true, -- 启用自动换行
                                linebreak = true, -- 在单词边界换行
                            },
                        },
                        show_token_count = false,
                        fold_context = true, -- 折叠上下文
                        fold_reasoning = true, -- 折叠推理输出
                        show_reasoning = true, -- 显示推理过程
                        auto_scroll = true, -- 启用自动滚动
                    },
                    diff = {
                        enabled = true,
                        provider = "inline", -- default|mini_diff|inline
                        provider_opts = {
                            inline = {
                                layout = "float", -- diff 显示为浮动窗口
                                show_keymap_hints = true, -- 显示快捷键提示
                                show_removed = true, -- 显示删除的内容
                            },
                        },
                    },
                },
                memory = {
                    opts = {
                        chat = {
                            enabled = true,
                            default_memory = "default", -- 明确指定默认内存组
                            default_params = "watch", -- 默认为 watch 模式
                            condition = function(chat)
                                -- 只在非 ACP 适配器时启用内存
                                return chat.adapter.type ~= "acp"
                            end,
                        },
                    },
                },

                -- 策略配置
                strategies = {
                    chat = {
                        adapter = get_default_adapter(),
                        roles = {
                            llm = function(adapter)
                                return "CodeCompanion (" .. adapter.formatted_name .. ")"
                            end,
                            user = "我",
                        },
                        -- Slash Commands 配置
                        slash_commands = {
                            ["buffer"] = {
                                opts = vim.tbl_extend("force", slash_command_defaults, {
                                    default_params = "watch", -- 默认 watch 模式
                                }),
                            },
                            ["file"] = { opts = slash_command_defaults },
                            ["symbols"] = { opts = slash_command_defaults },
                            ["help"] = { opts = slash_command_defaults },
                            ["workspace"] = { opts = slash_command_defaults },
                            ["terminal"] = { opts = slash_command_defaults },
                            ["fetch"] = {
                                opts = vim.tbl_extend("force", slash_command_defaults, {
                                    auto_restore_cache = true, -- 自动恢复缓存
                                }),
                            },
                        },
                        -- 工具配置
                        tools = {
                            opts = {
                                default_tools = {
                                    "full_stack_dev",
                                    "search_web",
                                    "fetch_webpage",
                                },
                                auto_submit_errors = true, -- 自动提交工具错误
                                auto_submit_success = false, -- 不自动提交成功消息
                            },
                        },
                        -- 优化设置
                        opts = {
                            submit_delay = 1, -- 减少提交延迟到1秒（避免频繁触发）
                            auto_submit = false, -- 禁用自动提交，需要用户确认
                        },
                    },
                    inline = {
                        adapter = adapter_usage.inline,
                    },
                },

                -- 扩展配置
                extensions = {
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
                                max_title_length = 50, -- 限制标题长度
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
                            show_tool_progress = true, -- 显示工具执行进度
                            show_adapter_change = true, -- 显示适配器切换
                        },
                    },
                },
            }
        end,
        keys = {
            { "<C-a>", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "CodeCompanionActions" },
            -- stylua: ignore
            { "<Leader>cc", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "Toggle CodeCompanionChat" },
            { "ga", "<cmd>CodeCompanionChat Add<cr>", mode = { "v" }, desc = "Add selection to CodeCompanionChat" },
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
            adapters = {
                -- 启用/禁用特定适配器（默认全部启用）
                anthropic_oauth = true, -- Anthropic Claude
                codex_oauth = true, -- OpenAI Codex/ChatGPT
                gemini_oauth = true, -- Google Gemini
                antigravity_oauth = true, -- Google Antigravity
            },
        },
    },
}

