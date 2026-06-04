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
                "ravitemer/mcphub.nvim",
                build = "bundled_build.lua",
                dependencies = {
                    "nvim-lua/plenary.nvim",
                },
                opts = {
                    use_bundled_binary = true,
                    auto_approve = false,
                    auto_toggle_mcp_servers = true,
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
