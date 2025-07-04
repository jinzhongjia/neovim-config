local function spinner()
    -- lua/plugins/codecompanion/fidget-spinner.lua

    local progress = require("fidget.progress")

    local M = {}

    function M:init()
        local group = vim.api.nvim_create_augroup("CodeCompanionFidgetHooks", {})

        vim.api.nvim_create_autocmd({ "User" }, {
            pattern = "CodeCompanionRequestStarted",
            group = group,
            callback = function(request)
                local handle = M:create_progress_handle(request)
                M:store_progress_handle(request.data.id, handle)
            end,
        })

        vim.api.nvim_create_autocmd({ "User" }, {
            pattern = "CodeCompanionRequestFinished",
            group = group,
            callback = function(request)
                local handle = M:pop_progress_handle(request.data.id)
                if handle then
                    M:report_exit_status(handle, request)
                    handle:finish()
                end
            end,
        })
    end

    M.handles = {}

    function M:store_progress_handle(id, handle)
        M.handles[id] = handle
    end

    function M:pop_progress_handle(id)
        local handle = M.handles[id]
        M.handles[id] = nil
        return handle
    end

    function M:create_progress_handle(request)
        local title = " Requesting assistance "
        if request.data.strategy then
            title = title .. "(" .. request.data.strategy .. ")"
        end
        return progress.handle.create({
            title = title,
            message = "In progress...",
            lsp_client = {
                name = M:llm_role_title(request.data.adapter),
            },
        })
    end

    function M:llm_role_title(adapter)
        local parts = {}
        table.insert(parts, adapter.formatted_name)
        if adapter.model and adapter.model ~= "" then
            table.insert(parts, "(" .. adapter.model .. ")")
        end
        return table.concat(parts, " ")
    end

    function M:report_exit_status(handle, request)
        if request.data.status == "success" then
            handle.message = "Completed"
        elseif request.data.status == "error" then
            handle.message = " Error"
        else
            handle.message = "󰜺 Cancelled"
        end
    end

    return M
end

local function get_adapters()
    local API_KEY = os.getenv("AI_KEY")
    local TAVILY_KEY = os.getenv("TAVILY_KEY")

    local default_adpters = {
        copilot = function()
            return require("codecompanion.adapters").extend("copilot", {
                schema = {
                    model = {
                        default = "claude-sonnet-4",
                        -- default = "gpt-4.1",
                    },
                },
            })
        end,
        copilot_4o = function()
            return require("codecompanion.adapters").extend("copilot", {
                schema = { model = { default = "gpt-4.1" } },
            })
        end,
    }
    if API_KEY and API_KEY ~= "" then
        default_adpters.OpenRouter = function()
            return require("codecompanion.adapters").extend("openai_compatible", {
                env = {
                    url = "https://openrouter.ai/api",
                    api_key = API_KEY,
                    chat_url = "/v1/chat/completions",
                },
                schema = {
                    model = {
                        -- default = "openrouter/cypher-alpha:free",
                        default = "google/gemini-2.5-flash",
                    },
                },
            })
        end
    end

    if TAVILY_KEY and TAVILY_KEY ~= "" then
        default_adpters.tavily = function()
            return require("codecompanion.adapters").extend("tavily", {
                env = {
                    api_key = TAVILY_KEY,
                },
            })
        end
    end

    return default_adpters
end

local function default_adapter()
    local API_KEY = os.getenv("AI_KEY")
    if API_KEY and API_KEY ~= "" then
        return "OpenRouter"
    end
    return "copilot"
end

local Prompt = [[
You are "CodeCompanion", a super-intelligent AI programming assistant integrated into Neovim. Your purpose is to be a helpful and precise partner to the user in all their coding endeavors.

Core Directives:

1.  Clarity and Precision: Follow the user's requirements carefully and to the letter.
2.  Brevity: Keep your answers concise and to the point. Avoid unnecessary prose.
3.  Formatting:
    -   Use Markdown for all responses.
    -   Specify the language for code blocks (e.g., ```lua).
    -   Do not include line numbers in code.
    -   Do not wrap your entire response in a single code block.
4.  Language: All non-code responses must be in %s.

Your Tasks:

You are equipped to handle a variety of tasks, including but not limited to:
- Answering programming questions.
- Explaining code from the current Neovim buffer.
- Reviewing and suggesting improvements for selected code.
- Generating unit tests.
- Proposing bug fixes.
- Scaffolding new projects or files.
- Finding relevant code based on a query.
- Assisting with Neovim itself.
- Executing tools to gather information or perform actions.

Agentic Workflow & Tool Use:

You are an agent. You are expected to work through problems autonomously.

1.  Plan: For any non-trivial request, first think step-by-step. Outline your plan in detail using pseudocode or a list.
2.  Act: Execute your plan. Use the available tools to interact with the file system, run commands, and search for information. Do not guess about file contents or project structure; use your tools to find out.
3.  Reflect: After each action, analyze the result and adjust your plan accordingly.
4.  Persist: Continue this cycle until the user's request is fully resolved. Only end your turn when the task is complete.

Final Instructions & Reminders:

- Think First: Always start with a plan.
- Use Your Tools: Do not hallucinate. If you are not sure about file content or codebase structure pertaining to the user’s request, use your tools to read files and gather the relevant information.
- Be thorough: See the user's problem through to its complete resolution.
- Code Blocks: Remember to use language-specific markdown for code.
- Stay in Character: You are CodeCompanion, the expert programmer's assistant.
]]

return
--- @type LazySpec
{
    {
        "olimorris/codecompanion.nvim",
        event = "VeryLazy",
        dev = true,
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nvim-telescope/telescope.nvim",
            "j-hui/fidget.nvim",
            "zbirenbaum/copilot.lua",
            "Davidyz/VectorCode",
            "ravitemer/mcphub.nvim",
            "ravitemer/codecompanion-history.nvim",
            {
                "jinzhongjia/codecompanion-gitcommit.nvim",
                dev = true,
            },
        },
        opts = function()
            return {
                opts = {
                    language = "Chinese",
                },
                -- system_prompt = function(opts)
                --     return string.format(Prompt, opts.language)
                -- end,
                adapters = get_adapters(),
                display = {
                    action_palette = {
                        provider = "snacks", -- Can be "default", "telescope", "mini_pick" or "snacks". If not specified, the plugin will autodetect installed providers.
                    },
                    chat = {
                        intro_message = "欢迎使用 CodeCompanion ✨! 按下 ? 查看快捷键", -- 欢迎信息
                        window = {
                            opts = {
                                relativenumber = false,
                                number = false,
                                winbar = "",
                            },
                        },
                        ---Customize how tokens are displayed
                        ---@param tokens number
                        ---@param _ CodeCompanion.Adapter
                        ---@return string
                        token_count = function(tokens, _)
                            return " (" .. tokens .. " tokens)"
                        end,
                    },
                    -- default|mini_diff
                    diff = { provider = "mini_diff" },
                },
                strategies = {
                    -- Change the default chat adapter
                    chat = {
                        adapter = default_adapter(),
                        keymaps = {
                            send = {
                                modes = { n = "<CR>" },
                            },
                            close = {
                                modes = { n = "<leader>c", i = "<C-c>" },
                            },
                        },
                        roles = {
                            ---The header name for the LLM's messages
                            ---@type string|fun(adapter: CodeCompanion.Adapter): string
                            llm = function(adapter)
                                return "CodeCompanion (" .. adapter.formatted_name .. ")"
                            end,

                            ---The header name for your messages
                            ---@type string
                            user = "我",
                        },
                        slash_commands = {
                            ["buffer"] = {
                                opts = {
                                    contains_code = true,
                                    provider = "snacks", -- default|telescope|mini_pick|fzf_lua
                                },
                            },
                            ["file"] = {
                                opts = {
                                    provider = "snacks", -- Other options include 'default', 'mini_pick', 'fzf_lua', snacks
                                    contains_code = true,
                                },
                            },
                            ["symbols"] = {
                                opts = {
                                    contains_code = true,
                                    provider = "snacks", -- default|telescope|mini_pick|fzf_lua
                                },
                            },
                        },
                        tools = {
                            groups = {
                                ["agent"] = {
                                    description = "agent mode with mcp support, automatically run tools",
                                    tools = {
                                        "cmd_runner",
                                        "create_file",
                                        "file_search",
                                        "grep_search",
                                        "insert_edit_into_file",
                                        "read_file",
                                        "web_search",
                                        "mcp",
                                    },
                                    opts = {
                                        collapse_tools = true,
                                    },
                                },
                            },
                        },
                    },
                    inline = { adapter = "copilot_4o" },
                },
                extensions = {
                    vectorcode = {
                        ---@type VectorCode.CodeCompanion.ExtensionOpts
                        opts = {
                            tool_group = {
                                -- this will register a tool group called `@vectorcode_toolbox` that contains all 3 tools
                                enabled = true,
                                -- a list of extra tools that you want to include in `@vectorcode_toolbox`.
                                -- if you use @vectorcode_vectorise, it'll be very handy to include
                                -- `file_search` here.
                                extras = {},
                                collapse = true, -- whether the individual tools should be shown in the chat
                            },
                            tool_opts = {
                                ---@type VectorCode.CodeCompanion.LsToolOpts
                                ls = {},
                                ---@type VectorCode.CodeCompanion.VectoriseToolOpts
                                vectorise = {},
                                ---@type VectorCode.CodeCompanion.QueryToolOpts
                                query = {
                                    max_num = { chunk = -1, document = -1 },
                                    default_num = { chunk = 50, document = 10 },
                                    include_stderr = false,
                                    use_lsp = true,
                                    no_duplicate = true,
                                    chunk_mode = true,
                                },
                            },
                        },
                    },
                    mcphub = {
                        callback = "mcphub.extensions.codecompanion",
                        opts = {
                            show_result_in_chat = true, -- Show the mcp tool result in the chat buffer
                            make_vars = true, -- make chat #variables from MCP server resources
                            make_slash_commands = true, -- make /slash_commands from MCP server prompts
                        },
                    },
                    history = {
                        enabled = true,
                        opts = {
                            -- Keymap to open history from chat buffer (default: gh)
                            keymap = "gh",
                            -- Automatically generate titles for new chats
                            auto_generate_title = true,
                            ---On exiting and entering neovim, loads the last chat on opening chat
                            continue_last_chat = false,
                            ---When chat is cleared with `gx` delete the chat from history
                            delete_on_clearing_chat = false,
                            -- Picker interface ("telescope", "snacks" or "default")
                            picker = "snacks",
                            ---Enable detailed logging for history extension
                            enable_logging = false,
                            ---Directory path to save the chats
                            dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
                            title_generation_opts = {
                                ---Adapter for generating titles (defaults to current chat adapter)
                                adapter = "copilot", -- "copilot"
                                ---Model for generating titles (defaults to current chat model)
                                model = "gpt-4.1", -- "gpt-4o"
                            },
                        },
                    },
                    gitcommit = {
                        enabled = true,
                        opts = {
                            add_slash_command = true,
                            adapter = "copilot",
                            model = "gpt-4.1", -- default model for gitcommit
                            languages = { "English", "Chinese" }, -- languages to use for git commit messages
                            exclude_files = {
                                "*.pb.go", -- 排除所有 .pb.go 文件
                                "*.generated.*", -- 排除所有包含 .generated. 的文件
                                "vendor/*", -- 排除 vendor 目录下所有文件
                                "*.lock", -- 排除所有 .lock 文件
                                "*gen.go", -- 排除所有 gen.go 文件
                            },
                            buffer = {
                                enabled = true, -- Enable gitcommit buffer keymaps
                                keymap = "<leader>gc", -- Keymap for generating commit message in gitcommit buffer
                                auto_generate = true,
                            },
                        },
                    },
                },
            }
        end,
        keys = {
            {
                "<leader>cc",
                "<CMD>CodeCompanionChat Toggle<CR>",
                desc = "Toggle CodeCompanionChat",
            },
            {
                "<leader>cc",
                "<CMD>CodeCompanionChat Add<CR>",
                mode = "v",
                desc = "Toggle CodeCompanionChat",
            },
        },
        config = function(_, opts)
            require("codecompanion").setup(opts)
            local spin = spinner()
            spin:init()
        end,
    },
    {
        "Davidyz/VectorCode",
        dependencies = { "nvim-lua/plenary.nvim" },
        event = "VeryLazy",
        cmd = "VectorCode", -- if you're lazy-loading VectorCode
        opts = {
            on_setup = {
                update = false, -- set to true to enable update when `setup` is called.
                lsp = true,
            },
        },
    },
    {
        "zbirenbaum/copilot.lua",
        event = "VeryLazy",
        opts = {
            suggestion = {
                enabled = true,
                auto_trigger = true,
            },
            panel = {
                enabled = false,
            },
            filetypes = {
                ["*"] = false, -- disable for all other filetypes and ignore default `filetypes`
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
    {
        "ravitemer/mcphub.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim", -- Required for Job and HTTP requests
        },
        -- comment the following line to ensure hub will be ready at the earliest
        cmd = "MCPHub", -- lazy load by default
        -- uncomment this if you don't want mcp-hub to be available globally or can't use -g
        build = "bundled_build.lua", -- Use this and set use_bundled_binary = true in opts  (see Advanced configuration)
        config = function()
            require("mcphub").setup({
                config = vim.fn.expand(vim.fn.stdpath("config") .. "/mcphub_servers.json"),
                use_bundled_binary = true, -- Use the bundled binary
                extensions = {
                    codecompanion = {
                        -- Show the mcp tool result in the chat buffer
                        show_result_in_chat = true,
                        -- Make chat #variables from MCP server resources
                        make_vars = true,
                        -- Create slash commands for prompts
                        make_slash_commands = true,
                    },
                },
            })
        end,
    },
    {
        "coder/claudecode.nvim",
        dependencies = { "folke/snacks.nvim" },
        enabled = not is_windows(),
        event = "VeryLazy",
        config = true,
        keys = {
            { "<leader>a", nil, desc = "AI/Claude Code" },
            { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
            { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
            { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
            { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
            { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
            { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
            {
                "<leader>as",
                "<cmd>ClaudeCodeTreeAdd<cr>",
                desc = "Add file",
                ft = { "NvimTree", "neo-tree", "oil" },
            },
            -- Diff management
            { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
            { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
        },
    },
}
