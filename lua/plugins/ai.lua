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

    -- local claude_code = require("extension.anthropic-oauth")
    -- local gemini_oauth = require("extension.gemini-oauth")
    -- local antigravity_oauth = require("extension.antigravity-oauth")
    -- local codex_oauth = require("extension.codex-oauth")

    -- Anthropic OAuth 适配器
    -- default_adpters.http.anthropic_oauth = claude_code

    -- Gemini OAuth 适配器
    -- default_adpters.http.gemini_oauth = gemini_oauth

    -- Antigravity OAuth 适配器
    -- default_adpters.http.antigravity_oauth = antigravity_oauth

    -- Codex OAuth 适配器 (ChatGPT Plus/Pro)
    -- default_adpters.http.codex_oauth = codex_oauth

    -- Anthropic OAuth - Inline 适配器
    -- default_adpters.http.inline_adapter = function()
    --     return require("codecompanion.adapters").extend("anthropic_oauth", {
    --         name = "inline_adapter",
    --         formatted_name = "Anthropic OAuth (Inline)",
    --         schema = { model = { default = DEFAULT_CLAUDE_AUTH_MIDDLE_MODEL } },
    --     })
    -- end

    -- default_adpters.acp.claude_code = function()
    --     return require("codecompanion.adapters").extend("claude_code", {
    --         env = {
    --             ANTHROPIC_API_KEY = function()
    --                 return claude_code.get_api_key()
    --             end,
    --         },
    --     })
    -- end

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

            -- 扩展插件
            "Davidyz/VectorCode",
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
                        -- keymaps = {
                        --     send = { modes = { n = "<CR>", i = "<C-s>" } }, -- 增加 insert 模式快捷键
                        --     close = { modes = { n = "q", i = "<C-c>" } }, -- 改为 q 键关闭
                        --     regenerate = { modes = { n = "gr" } }, -- 重新生成回复
                        --     yank_code = { modes = { n = "gy" } }, -- 复制代码块
                        --     pin_context = { modes = { n = "gp" } }, -- 固定上下文
                        --     clear = { modes = { n = "gx" } }, -- 清空聊天
                        -- },
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
                        -- keymaps = {
                        --     accept_change = { modes = { n = "ga" } },
                        --     reject_change = { modes = { n = "gr" } },
                        -- },
                    },
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
        config = function()
            require("mcphub").setup({
                config = vim.fn.expand(vim.fn.stdpath("config") .. "/mcphub_servers.json"),
                auto_approve = true,
            })
        end,
    },

    -- ========== ClaudeCode ==========
    {
        "coder/claudecode.nvim",
        dependencies = { "folke/snacks.nvim" },
        dev = true,
        cond = function()
            -- Only load on non-Windows systems
            return vim.fn.has("win32") == 0
        end,
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
                ft = { "NvimTree", "neo-tree", "fyler", "minifiles" },
            },
            { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
            { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
        },
        opts = {
            -- 服务器配置
            port_range = { min = 10000, max = 65535 },
            auto_start = true,
            log_level = "info", -- "trace", "debug", "info", "warn", "error"

            -- 发送/聚焦行为
            -- 成功发送后自动聚焦 Claude 终端（如果已连接）
            focus_after_send = false,

            -- 选择跟踪
            track_selection = true,
            visual_demotion_delay_ms = 50,

            -- 终端配置
            terminal = {
                split_side = "right", -- "left" 或 "right"
                split_width_percentage = 0.30,
                provider = "auto", -- "auto", "snacks", "native", "external", "none"
                auto_close = true,

                -- Snacks 窗口选项（可选：配置为浮动窗口）
                -- snacks_win_opts = {
                --     position = "float",
                --     width = 0.85,
                --     height = 0.85,
                --     border = "rounded",
                --     keys = {
                --         claude_hide = {
                --             "<Esc>",
                --             function(self)
                --                 self:hide()
                --             end,
                --             mode = "t",
                --             desc = "Hide",
                --         },
                --     },
                -- },
            },

            -- Diff 集成
            diff_opts = {
                auto_close_on_accept = true,
                vertical_split = true,
                open_in_current_tab = true,
                keep_terminal_focus = false, -- true 时在打开 diff 后将焦点移回终端
            },

            -- 工作目录控制（可选）
            -- git_repo_cwd = true, -- 使用 git 仓库根目录
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

    -- ========== Sidekick - Copilot Next Edit Suggestions ==========
    {
        "folke/sidekick.nvim",
        event = "VeryLazy",
        dependencies = {
            "zbirenbaum/copilot.lua", -- Copilot LSP server
            "neovim/nvim-lspconfig", -- LSP configuration
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
            -- 跳转设置
            jump = {
                jumplist = true, -- 添加跳转到 jumplist
            },
            -- Next Edit Suggestions 配置
            nes = {
                enabled = function(buf)
                    return vim.g.sidekick_nes ~= false and vim.b.sidekick_nes ~= false
                end,
                debounce = 100, -- 防抖延迟（毫秒）
                trigger = {
                    -- 触发 NES 的事件
                    events = { "ModeChanged i:n", "TextChanged", "User SidekickNesDone" },
                },
                clear = {
                    -- 清除 NES 的事件
                    events = { "TextChangedI", "InsertEnter" },
                    esc = true, -- 按 ESC 清除建议
                },
                diff = {
                    inline = "words", -- 内联 diff 模式: "words" | "chars" | false
                },
            },
            -- 完全禁用 CLI 功能
            cli = {
                enabled = false,
            },
            -- Copilot 状态跟踪
            copilot = {
                status = {
                    enabled = true, -- 启用状态跟踪
                    level = vim.log.levels.WARN, -- 通知级别
                },
            },
            debug = false,
        },
        keys = {
            -- ===== Next Edit Suggestions (NES) 快捷键 =====
            -- Tab: 跳转到下一个编辑位置或应用所有编辑
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
                mode = "n", -- 仅在 normal 模式下，insert 模式由 blink.cmp 处理
            },

            -- 手动触发更新建议
            {
                "<leader>su",
                function()
                    require("sidekick.nes").update()
                end,
                desc = "Sidekick: Update suggestions",
            },

            -- 跳转到编辑位置
            {
                "<leader>sj",
                function()
                    require("sidekick.nes").jump()
                end,
                desc = "Sidekick: Jump to edit",
            },

            -- 应用编辑
            {
                "<leader>sa",
                function()
                    require("sidekick.nes").apply()
                end,
                desc = "Sidekick: Apply edit",
            },

            -- 清除所有建议
            {
                "<leader>sx",
                function()
                    require("sidekick").clear()
                end,
                desc = "Sidekick: Clear suggestions",
            },

            -- 切换 NES 功能开关
            {
                "<leader>st",
                function()
                    require("sidekick.nes").toggle()
                end,
                desc = "Sidekick: Toggle NES",
            },
        },
    },
    {
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
            default = {
                prompt_for_file_name = false,
            },
            filetypes = {
                codecompanion = {
                    url_encode_path = true,
                    template = "![$CURSOR]($FILE_PATH)",
                    use_absolute_path = true,
                },
            },
        },
        keys = {
            { "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste image from clipboard" },
        },
    },
}
