-- codecompanion yolo mode
vim.g.codecompanion_yolo_mode = true

-- ========================
-- 通用常量配置
-- ========================
local DEFAULT_COPILOT_MODEL = "gpt-4.1"
local DEFAULT_CLAUDE_MODEL = "claude-sonnet-4"

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
    local default_adpters = {
        http = {},
        acp = {},
    }

    -- Copilot 适配器
    default_adpters.http.copilot = function()
        return require("codecompanion.adapters").extend("copilot", {
            schema = {
                model = {
                    default = DEFAULT_CLAUDE_MODEL,
                },
            },
        })
    end

    default_adpters.http.copilot_4_1 = function()
        return require("codecompanion.adapters").extend("copilot", {
            schema = { model = { default = DEFAULT_COPILOT_MODEL } },
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
                schema = {
                    model = {
                        default = "glm-4.5",
                    },
                },
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
                schema = {
                    model = {
                        default = "openrouter/horizon-alpha",
                    },
                },
            })
        end
    end

    -- Tavily 适配器（用于网页搜索）
    if env.TAVILY_KEY and env.TAVILY_KEY ~= "" then
        default_adpters.http.tavily = function()
            return require("codecompanion.adapters").extend("tavily", {
                env = {
                    api_key = env.TAVILY_KEY,
                },
            })
        end
    end

    -- LLM Router 适配器
    if env.LLM_ROUTER_URL and env.LLM_ROUTER_URL ~= "" then
        default_adpters.http.llm_router = function()
            return require("codecompanion.adapters").extend("openai_compatible", {
                name = "llm_router",
                formatted_name = "LLM Router",
                env = {
                    url = env.LLM_ROUTER_URL,
                    api_key = "*******",
                },
                schema = {
                    model = {
                        default = "claude-4-opus",
                    },
                },
            })
        end
    end

    local claude_code = require("extension.anthropic-oauth")

    -- Anthropic OAuth 适配器
    default_adpters.http.anthropic_oauth = claude_code

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
    default_adpters.http.opts = {
        show_defaults = false,
        show_model_choices = true,
    }

    return default_adpters
end

-- ========================
-- 默认适配器选择
-- ========================
local get_default_adapter = function()
    -- if env.LLM_ROUTER_URL and env.LLM_ROUTER_URL ~= "" then
    --     return "llm_router"
    -- end
    return "anthropic_oauth"
end

-- ========================
-- 系统提示词
-- ========================
local system_prompt = [[
You are an AI programming assistant named "CodeCompanion". You are currently plugged in to the Neovim text editor on a user's machine.

Your core tasks include:
- Answering general programming questions.
- Explaining how the code in a Neovim buffer works.
- Reviewing the selected code in a Neovim buffer.
- Generating unit tests for the selected code.
- Proposing fixes for problems in the selected code.
- Scaffolding code for a new workspace.
- Finding relevant code to the user's query.
- Proposing fixes for test failures.
- Answering questions about Neovim.
- Running tools.

You must:
- **Be proactive and thorough in executing the user's direct requests.**
- **Ask permission before providing additional help beyond the request.**
- Follow the user's requirements carefully and to the letter.
- Keep your answers short and impersonal, especially if the user responds with context outside of your tasks.
- Minimize other prose.
- Use Markdown formatting in your answers.
- Include the programming language name at the start of the Markdown code blocks.
- Avoid including line numbers in code blocks.
- Avoid wrapping the whole response in triple backticks.
- Only return code that's relevant to the task at hand. You may not need to return all of the code that the user has shared.
- Use actual line breaks instead of '\n' in your response to begin new lines.
- Use '\n' only when you want a literal backslash followed by a character 'n'.
- All non-code responses must be in %s.

**Response Strategy:**

**Direct Requests (execute immediately and thoroughly):**
- Answer the specific programming question
- Generate the requested code with appropriate detail
- Explain the specified code sections
- Review and provide feedback on selected code
- Fix identified problems or bugs
- Create tests when explicitly asked
- Scaffold requested project structures

**Additional Help (ask permission first):**
- Suggesting improvements or optimizations not requested
- Providing alternative approaches or examples
- Recommending related tools, libraries, or best practices  
- Adding extra features or functionality
- Offering to create related code (tests, documentation, etc.)
- Proposing follow-up tasks or next steps

**Permission Request Format:**
After completing the core request, if additional help would be valuable, ask:
"Would you like me to also [specific action]?"

**Examples:**
- "Would you like me to also add input validation to this function?"
- "Should I create unit tests for this code as well?"
- "Would you like suggestions for improving performance?"
- "Should I show you alternative implementations?"

**When given a task:**
1. Complete the requested task thoroughly and proactively.
2. If you identify valuable additional help, ask permission with a brief, specific question.
3. You can only give one reply for each conversation turn.
]]

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
                    system_prompt = function(opts)
                        return string.format(system_prompt, opts.language or "English")
                    end,
                    language = "Chinese",
                },

                -- 适配器配置
                adapters = get_adapters(),

                -- 显示配置
                display = {
                    action_palette = {
                        provider = "snacks",
                    },
                    chat = {
                        intro_message = "欢迎使用 CodeCompanion ✨! 按下 ? 查看快捷键",
                        window = {
                            opts = {
                                relativenumber = false,
                                number = false,
                                winbar = "",
                            },
                        },
                        show_token_count = false,
                        fold_context = true,
                    },
                    diff = {
                        provider = "inline", -- default|mini_diff|inline
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
                            opts = { default_tools = { "full_stack_dev" } },
                        },
                    },
                    inline = { adapter = "copilot_4_1" },
                },

                -- 扩展配置
                extensions = {
                    -- VectorCode 扩展
                    vectorcode = {
                        opts = {
                            tool_group = {
                                enabled = true,
                                extras = {},
                                collapse = true,
                            },
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
                                    summarise = {
                                        enabled = false,
                                        adapter = nil,
                                        query_augmented = true,
                                    },
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
                            add_mcp_prefix_to_tool_names = false,
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
                                adapter = "copilot",
                                model = DEFAULT_COPILOT_MODEL,
                            },
                        },
                    },

                    -- Git Commit 扩展
                    gitcommit = {
                        enabled = true,
                        opts = {
                            add_slash_command = true,
                            adapter = "copilot",
                            model = DEFAULT_COPILOT_MODEL,
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
                adapter = "copilot",
                model = DEFAULT_COPILOT_MODEL,
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
}
