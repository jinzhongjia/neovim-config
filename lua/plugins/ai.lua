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
        if request.data.adapter and request.data.adapter.formatted_name then
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
                adapters = {
                    copilot = function()
                        return require("codecompanion.adapters").extend("copilot", {
                            schema = {
                                model = {
                                    -- default = "gpt-4.1",
                                    -- default = "claude-sonnet-4",
                                    default = "gemini-2.5-pro-preview-06-05",
                                },
                            },
                        })
                    end,
                    copilot_4o = function()
                        return require("codecompanion.adapters").extend("copilot", {
                            schema = {
                                model = {
                                    -- default = "gpt-4o",
                                    default = "gpt-4.1",
                                    -- default = "claude-sonnet-4",
                                },
                            },
                        })
                    end,
                },
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
                        adapter = "copilot",
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
                            ["git_files"] = {
                                description = "List git files",
                                ---@param chat CodeCompanion.Chat
                                callback = function(chat)
                                    local handle = vim.system({ "git", "ls-files" }, { text = true })
                                    local result = handle:wait()
                                    if result.code ~= 0 then
                                        return vim.notify(
                                            "No git files available",
                                            vim.log.levels.INFO,
                                            { title = "CodeCompanion" }
                                        )
                                    end
                                    --- @type string
                                    local str = string.format(
                                        "Here is the result of running command `git ls-files` locally, you can use it as a data: \n```sh\n%s\n```",
                                        result.stdout
                                    )
                                    chat:add_reference({ role = "user", content = str }, "git", "<git_files>")
                                end,
                                opts = {
                                    contains_code = false,
                                },
                            },
                            codebase = require("vectorcode.integrations").codecompanion.chat.make_slash_command(),
                        },
                    },
                    inline = { adapter = "copilot_4o" },
                },
                extensions = {
                    vectorcode = {
                        opts = {
                            add_tool = true,
                            add_slash_command = true,
                            ---@type VectorCode.CodeCompanion.ToolOpts
                            tool_opts = {
                                use_lsp = true,
                                ls_on_start = false,
                                no_duplicate = true,
                                chunk_mode = true,
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
        commit = "91d0d8db26293311e88265eab275ebf37c1e793e",
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
}
