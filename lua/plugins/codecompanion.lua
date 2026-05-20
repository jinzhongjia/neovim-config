return
--- @type LazySpec
{
    {
        "olimorris/codecompanion.nvim",
        version = "^19.0.0",
        cmd = {
            "CodeCompanion",
            "CodeCompanionActions",
            "CodeCompanionChat",
            "CodeCompanionCmd",
            "CodeCompanionHistory",
            "CodeCompanionSummaries",
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "ravitemer/codecompanion-history.nvim",
            {
                "Davidyz/VectorCode",
                version = "*",
                build = "uv tool upgrade vectorcode",
                dependencies = { "nvim-lua/plenary.nvim" },
                opts = {
                    async_opts = {
                        n_query = 3,
                        notify = false,
                        run_on_register = false,
                    },
                    n_query = 3,
                    notify = true,
                    timeout_ms = 10000,
                },
            },
            {
                "ravitemer/mcphub.nvim",
                build = "bundled_build.lua",
                dependencies = {
                    "nvim-lua/plenary.nvim",
                    {
                        "Joakker/lua-json5",
                        build = "./install.sh",
                    },
                },
                opts = {
                    use_bundled_binary = true,
                    auto_approve = false,
                    auto_toggle_mcp_servers = true,
                    json_decode = function(str)
                        return require("json5").parse(str)
                    end,
                    workspace = {
                        enabled = true,
                        look_for = { ".mcphub/servers.json", ".vscode/mcp.json", ".cursor/mcp.json" },
                        reload_on_dir_changed = true,
                    },
                    ui = {
                        window = {
                            width = 0.85,
                            height = 0.85,
                            border = "rounded",
                        },
                    },
                },
            },
        },
        opts = {
            extensions = {
                history = {
                    enabled = true,
                    opts = {
                        keymap = "gh",
                        save_chat_keymap = "sc",
                        auto_save = true,
                        picker = "snacks",
                        continue_last_chat = false,
                        delete_on_clearing_chat = false,
                        expiration_days = 0,
                        dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
                        title_generation_opts = {
                            adapter = "copilot",
                            refresh_every_n_prompts = 0,
                            max_refreshes = 3,
                        },
                        summary = {
                            create_summary_keymap = "gcs",
                            browse_summaries_keymap = "gbs",
                        },
                        memory = {
                            auto_create_memories_on_summary_generation = true,
                            vectorcode_exe = "vectorcode",
                            notify = true,
                            index_on_startup = false,
                        },
                    },
                },
                mcphub = {
                    callback = "mcphub.extensions.codecompanion",
                    opts = {
                        make_vars = false,
                        make_slash_commands = true,
                        show_result_in_chat = true,
                    },
                },
                vectorcode = {
                    opts = {
                        tool_group = {
                            enabled = true,
                            extras = { "file_search" },
                            collapse = false,
                        },
                        tool_opts = {
                            ["*"] = {
                                use_lsp = false,
                            },
                            query = {
                                default_num = { chunk = 20, document = 5 },
                                max_num = { chunk = 50, document = 10 },
                                no_duplicate = true,
                                chunk_mode = false,
                                summarise = {
                                    enabled = false,
                                },
                            },
                            vectorise = {
                                require_approval_before = true,
                            },
                        },
                    },
                },
            },
            interactions = {
                chat = {
                    adapter = "opencode",
                    opts = {
                        completion_provider = "blink",
                    },
                    slash_commands = {
                        file = {
                            opts = {
                                provider = "snacks",
                            },
                        },
                        buffer = {
                            opts = {
                                provider = "snacks",
                            },
                        },
                        symbols = {
                            opts = {
                                provider = "snacks",
                            },
                        },
                    },
                },
            },
            display = {
                action_palette = {
                    provider = "snacks",
                    opts = {
                        title = "CodeCompanion actions",
                        show_preset_actions = true,
                        show_preset_prompts = true,
                        show_preset_rules = true,
                    },
                },
                chat = {
                    window = {
                        layout = "vertical",
                        position = "right",
                        width = 0.4,
                        border = "rounded",
                        opts = {
                            number = false,
                            relativenumber = false,
                            signcolumn = "no",
                            foldcolumn = "0",
                            statuscolumn = "",
                        },
                    },
                    fold_context = true,
                    show_header_separator = false,
                    start_in_insert_mode = false,
                },
                diff = {
                    enabled = true,
                    window = {
                        opts = {
                            number = true,
                        },
                    },
                },
            },
            opts = {
                language = "Chinese",
                log_level = "ERROR",
            },
        },
        keys = {
            { "<leader>c", nil, desc = "CodeCompanion" },
            { "<leader>cc", "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle chat" },
            { "<leader>cx", "<cmd>CodeCompanionActions<cr>", desc = "Actions" },
            { "<leader>ci", "<cmd>CodeCompanion<cr>", mode = { "n", "v" }, desc = "Inline prompt" },
            { "<leader>ch", "<cmd>CodeCompanionHistory<cr>", desc = "Chat history" },
            { "<leader>cs", "<cmd>CodeCompanionSummaries<cr>", desc = "Chat summaries" },
            { "<leader>cm", "<cmd>MCPHub<cr>", desc = "MCP Hub" },
            { "<leader>cp", "<cmd>CodeCompanionChat Add<cr>", mode = { "v" }, desc = "Add selection to chat" },
        },
    },
    {
        "HakonHarnes/img-clip.nvim",
        cmd = { "PasteImage", "ImgClipDebug", "ImgClipConfig" },
        opts = {
            default = {
                dir_path = "assets/images",
                prompt_for_file_name = false,
                show_dir_path_in_prompt = true,
            },
            filetypes = {
                codecompanion = {
                    prompt_for_file_name = false,
                    template = "[Image]($FILE_PATH)",
                    use_absolute_path = true,
                },
                markdown = {
                    dir_path = "assets/images",
                    prompt_for_file_name = false,
                    template = "![$CURSOR]($FILE_PATH)",
                },
            },
        },
        keys = {
            { "<leader>cP", "<cmd>PasteImage<cr>", desc = "Paste image" },
        },
    },
}
