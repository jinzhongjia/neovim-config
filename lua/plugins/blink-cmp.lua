return
--- @type LazySpec
{
    {
        "saghen/blink.cmp",
        version = "*",
        dependencies = {
            "folke/lazydev.nvim",
        },
        event = "VeryLazy",
        opts = {
            sources = {
                default = {
                    "lsp",
                    "lazydev",
                    "path",
                    "snippets",
                    "buffer",
                },
                per_filetype = {
                    codecompanion = { "codecompanion" },
                },
                providers = {
                    lsp = { score_offset = 11 },
                    buffer = { score_offset = 8 },
                    path = { score_offset = 8 },
                    snippets = { opts = { search_paths = { my_snippets_path } }, score_offset = 9 },
                    lazydev = {
                        name = "LazyDev",
                        module = "lazydev.integrations.blink",
                        -- make lazydev completions top priority (see `:h blink.cmp`)
                        score_offset = 10,
                    },
                },
            },
            completion = {
                accept = { auto_brackets = { enabled = true } },
                list = { max_items = 50, selection = { preselect = false, auto_insert = false } },
                menu = {
                    border = "rounded",
                    auto_show = true,
                },
                documentation = { auto_show = true, auto_show_delay_ms = 250, window = { border = "rounded" } },
            },
            cmdline = {
                completion = {
                    menu = { auto_show = true },
                    list = { selection = { preselect = false, auto_insert = true } },
                },
                keymap = { preset = "inherit" },
            },
            keymap = {
                -- set to 'none' to disable the 'default' preset
                preset = "none",

                -- prev
                ["<C-k>"] = { "select_prev", "fallback" },
                -- next
                ["<C-j>"] = { "select_next", "fallback" },

                -- show
                ["<A-.>"] = { "show" },
                -- hide
                ["<A-,>"] = { "hide" },
                ["<A-;>"] = {
                    function(cmp)
                        local copilot_suggestion = require("copilot.suggestion")
                        copilot_suggestion.toggle_auto_trigger()
                    end,
                },
                ["<A-'>"] = {
                    function(cmp)
                        local copilot_suggestion = require("copilot.suggestion")
                        if copilot_suggestion.is_visible() then
                            copilot_suggestion.dismiss()
                        else
                            copilot_suggestion.next()
                        end
                    end,
                },

                -- accept
                ["<CR>"] = { "accept", "fallback" },

                -- doc up
                ["<C-b>"] = { "scroll_documentation_up", "fallback" },
                -- doc down
                ["<C-f>"] = { "scroll_documentation_down", "fallback" },

                -- next snippet
                ["<C-l>"] = { "snippet_forward", "fallback" },
                -- prev snippet
                ["<C-h>"] = { "snippet_backward", "fallback" },

                -- tab
                ["<Tab>"] = {
                    function(cmp)
                        local copilot_suggestion = require("copilot.suggestion")
                        -- 1. 如果补全菜单可见，选择下一项
                        if cmp.is_visible() then
                            return cmp.select_next()
                            -- 2. 如果 copilot suggestion 可见，接受它
                        elseif copilot_suggestion.is_visible() then
                            if cmp.snippet_active() then
                                vim.snippet.stop()
                            end
                            copilot_suggestion.accept()
                            return true
                            -- 3. 如果在 snippet 中，跳转到下一个位置
                        elseif cmp.snippet_active({ direction = 1 }) then
                            return cmp.snippet_forward()
                        end
                        return false
                    end,
                    "fallback",
                },
                -- shift tab
                ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
            },
        },
        opts_extend = { "sources.default" },
    },
}
