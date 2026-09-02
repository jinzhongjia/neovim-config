-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Completion — blink.cmp (replaces the native vim.lsp.completion setup)
-- Fuzzy matcher is a prebuilt Rust binary, auto-downloaded because the
-- plugin is pinned to a release tag in plugins/init.lua
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

require("blink.cmp").setup({
    sources = {
        default = { "lsp", "lazydev", "path", "snippets", "buffer" },
        providers = {
            lsp = { score_offset = 11 },
            lazydev = {
                name = "LazyDev",
                module = "lazydev.integrations.blink",
                -- require/module 补全优先于 LuaLS 的普通补全
                score_offset = 100,
            },
            snippets = { score_offset = 9 },
            buffer = { score_offset = 8 },
            path = { score_offset = 8 },
        },
    },

    completion = {
        accept = { auto_brackets = { enabled = true } },
        list = { max_items = 50, selection = { preselect = false, auto_insert = false } },
        menu = { border = "rounded", auto_show = true },
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

        -- prev / next
        ["<C-k>"] = { "select_prev", "fallback" },
        ["<C-j>"] = { "select_next", "fallback" },

        -- show / hide
        ["<A-.>"] = { "show" },
        ["<A-,>"] = { "hide" },

        -- copilot: 切换自动触发
        ["<A-;>"] = {
            function()
                require("copilot.suggestion").toggle_auto_trigger()
            end,
        },
        -- copilot: 可见则关掉，否则要下一条建议
        ["<A-'>"] = {
            function()
                local suggestion = require("copilot.suggestion")
                if suggestion.is_visible() then
                    suggestion.dismiss()
                else
                    suggestion.next()
                end
            end,
        },

        -- accept
        ["<CR>"] = { "accept", "fallback" },

        -- doc scroll
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },

        -- snippet jump
        ["<C-l>"] = { "snippet_forward", "fallback" },
        ["<C-h>"] = { "snippet_backward", "fallback" },

        ["<Tab>"] = {
            function(cmp)
                local suggestion = require("copilot.suggestion")
                -- 1. 如果补全菜单可见，选择下一项
                if cmp.is_visible() then
                    return cmp.select_next()
                -- 2. 如果 copilot suggestion 可见，接受它
                elseif suggestion.is_visible() then
                    if cmp.snippet_active() then
                        vim.snippet.stop()
                    end
                    suggestion.accept()
                    return true
                -- 3. 如果在 snippet 中，跳转到下一个位置
                elseif cmp.snippet_active({ direction = 1 }) then
                    return cmp.snippet_forward()
                end
                return false
            end,
            "fallback",
        },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
    },
})

-- Advertise blink's capabilities to every server. Merges into the '*'
-- config; servers only start on FileType, well after this runs.
vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })
