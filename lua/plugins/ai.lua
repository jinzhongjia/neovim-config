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
        return progress.handle.create({
            title = " Requesting assistance (" .. request.data.strategy .. ")",
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
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nvim-telescope/telescope.nvim",
            "j-hui/fidget.nvim",
            {
                "zbirenbaum/copilot.lua",
                opts = {
                    suggestion = { enabled = false },
                    panel = { enabled = false },
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
                    },
                },
            },
        },
        opts = {
            opts = {
                language = "Chinese",
            },
            adapters = {
                copilot = function()
                    return require("codecompanion.adapters").extend("copilot", {
                        schema = {
                            model = {
                                default = "claude-3.7-sonnet-thought",
                            },
                        },
                    })
                end,
            },
            display = {
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
                            modes = { n = "<CR>", i = "C-CR" },
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
                                provider = "telescope", -- default|telescope|mini_pick|fzf_lua
                            },
                        },
                        ["file"] = {
                            opts = {
                                provider = "default", -- Other options include 'default', 'mini_pick', 'fzf_lua', snacks
                                contains_code = true,
                            },
                        },
                        ["symbols"] = {
                            opts = {
                                contains_code = true,
                                provider = "telescope", -- default|telescope|mini_pick|fzf_lua
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
                                chat:add_reference({ content = result.stdout }, "git", "<git_files>")
                                -- local handle = io.popen("git ls-files")
                                -- if handle ~= nil then
                                --     local result = handle:read("*a")
                                --     handle:close()
                                --     chat:add_reference({ content = result }, "git", "<git_files>")
                                -- else
                                --     return vim.notify(
                                --         "No git files available",
                                --         vim.log.levels.INFO,
                                --         { title = "CodeCompanion" }
                                --     )
                                -- end
                            end,
                            opts = {
                                contains_code = false,
                            },
                        },
                    },
                },
                inline = { adapter = "copilot" },
            },
        },
        keys = {
            {
                "<leader>cc",
                ":CodeCompanionChat Toggle<CR>",
                desc = "Toggle CodeCompanionChat",
            },
        },
        init = function()
            local spin = spinner()
            spin:init()
        end,
    },
}
