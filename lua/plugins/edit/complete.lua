return
--- @type LazySpec
{
    {
        "saghen/blink.cmp",
        -- optional: provides snippets for the snippet source
        dependencies = {
            "rafamadriz/friendly-snippets",
            "onsails/lspkind.nvim",
            "folke/lazydev.nvim",
            -- "fang2hou/blink-copilot",
            "mikavilpas/blink-ripgrep.nvim",
            "hrisgrieser/nvim-scissors",
            { "Kaiser-Yang/blink-cmp-git", dependencies = { "nvim-lua/plenary.nvim" } },
            { "xzbdmw/colorful-menu.nvim", opts = {} },
            -- { "echasnovski/mini.pairs", version = "*" },
            {
                "saghen/blink.pairs",
                branch = "main",
                build = "cargo build --release",
                opts = {},
            },
            { "kristijanhusak/vim-dadbod-completion" },
        },
        event = "VeryLazy",
        version = "*",
        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            sources = {
                default = {
                    "lsp",
                    -- "copilot",
                    "lazydev",
                    "path",
                    "snippets",
                    "buffer",
                },
                per_filetype = {
                    codecompanion = { "codecompanion" },
                    sql = { "snippets", "dadbod" },
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
                    -- copilot = { name = "copilot", module = "blink-copilot", score_offset = 10, async = true },
                    dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
                    -- ripgrep = { module = "blink-ripgrep", name = "Ripgrep", score_offset = 7 },
                },
            },
            fuzzy = {
                implementation = "prefer_rust_with_warning",
                sorts = {
                    -- compare with the score
                    "score",
                    -- always prioritize exact matches
                    -- "exact",
                    -- low deprecated items
                    function(item_a, _)
                        if item_a.deprecated then
                            return false
                        end
                    end,
                    -- sort by the text of the completion
                    "sort_text",
                },
            },
            completion = {
                accept = { auto_brackets = { enabled = true, default_brackets = { "(", ")" } } },
                list = { max_items = 500, selection = { preselect = false, auto_insert = false } },
                menu = {
                    border = "rounded",
                    auto_show = true,
                    draw = {
                        columns = { { "kind_icon" }, { "label", gap = 1 } },
                        components = {
                            label = {
                                text = function(ctx)
                                    return require("colorful-menu").blink_components_text(ctx)
                                end,
                                highlight = function(ctx)
                                    return require("colorful-menu").blink_components_highlight(ctx)
                                end,
                            },
                            kind_icon = {
                                ellipsis = false,
                                text = function(ctx)
                                    local lspkind = require("lspkind")
                                    lspkind.init({ symbol_map = { Copilot = "" } })
                                    vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })
                                    local icon = ctx.kind_icon
                                    if vim.tbl_contains({ "Path" }, ctx.source_name) then
                                        local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
                                        if dev_icon then
                                            icon = dev_icon
                                        end
                                    else
                                        icon = require("lspkind").symbolic(ctx.kind, {
                                            mode = "symbol",
                                        })
                                    end

                                    return icon .. ctx.icon_gap
                                end,

                                -- Optionally, use the highlight groups from nvim-web-devicons
                                -- You can also add the same function for `kind.highlight` if you want to
                                -- keep the highlight groups in sync with the icons.
                                highlight = function(ctx)
                                    local hl = ctx.kind_hl
                                    if vim.tbl_contains({ "Path" }, ctx.source_name) then
                                        local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
                                        if dev_icon then
                                            hl = dev_hl
                                        end
                                    end
                                    return hl
                                end,
                            },
                        },
                    },
                },
                documentation = { auto_show = true, auto_show_delay_ms = 200, window = { border = "rounded" } },
                -- ghost_text = {
                --     enabled = true,
                --     show_with_menu = true,
                -- },
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
                        if cmp.is_visible() then
                            return cmp.select_next()
                        elseif cmp.snippet_active({ direction = 1 }) then
                            return cmp.snippet_forward()
                        elseif copilot_suggestion.is_visible() then
                            copilot_suggestion.accept()
                            return true
                        end
                        return false
                    end,
                    -- "select_next",
                    -- "snippet_forward",
                    "fallback",
                },
                -- shift tab
                ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
            },
        },
        opts_extend = { "sources.default" },
    },
}
