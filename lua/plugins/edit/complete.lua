return
--- @type LazySpec
{
    {
        "saghen/blink.cmp",
        enabled = complete_engine == "blink",
        -- optional: provides snippets for the snippet source
        dependencies = {
            "rafamadriz/friendly-snippets",
            "onsails/lspkind.nvim",
            "folke/lazydev.nvim",
            "fang2hou/blink-copilot",
            "mikavilpas/blink-ripgrep.nvim",
            "hrisgrieser/nvim-scissors",
            {
                "Kaiser-Yang/blink-cmp-git",
                dependencies = { "nvim-lua/plenary.nvim" },
            },
            { "xzbdmw/colorful-menu.nvim", opts = {} },
            {
                "echasnovski/mini.pairs",
                version = "*",
                event = "VeryLazy",
                opts = {},
            },
        },
        event = "VeryLazy",
        version = "*",
        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            sources = {
                default = { "lsp", "copilot", "lazydev", "path", "snippets", "buffer", "ripgrep" },
                per_filetype = { codecompanion = { "codecompanion" } },
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
                    copilot = { name = "copilot", module = "blink-copilot", score_offset = 10, async = true },
                    ripgrep = { module = "blink-ripgrep", name = "Ripgrep", score_offset = 7 },
                },
            },
            fuzzy = {
                implementation = "prefer_rust_with_warning",
                sorts = {
                    -- compare with the score
                    "score",
                    -- always prioritize exact matches
                    "exact",
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
                ghost_text = {
                    enabled = true,
                    show_with_menu = true,
                },
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
                ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
                -- shift tab
                ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
            },
        },
        opts_extend = { "sources.default" },
    },
    {
        "hrsh7th/nvim-cmp",
        enabled = complete_engine == "cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-calc",
            "hrsh7th/cmp-nvim-lsp-document-symbol",
            -- ai support copilot
            {
                "zbirenbaum/copilot-cmp",
                dependencies = {
                    "zbirenbaum/copilot.lua",
                },
                opts = {},
            },
            -- async path
            {
                "FelipeLema/cmp-async-path",
                url = "https://codeberg.org/FelipeLema/cmp-async-path",
            },
            -- source for git
            {
                "petertriho/cmp-git",
                opts = {},
            },
            -- ripgrep support
            {
                "lukas-reineke/cmp-rg",
            },
            { "garymjr/nvim-snippets" },
            --- ui denpendences
            { "onsails/lspkind-nvim" },
            { "xzbdmw/colorful-menu.nvim", opts = {} },
            --- autopairs
            {
                "windwp/nvim-autopairs",
                opts = {
                    disable_filetype = {
                        "TelescopePrompt",
                        "spectre_panel",
                        "codecompanion",
                        "snacks_input",
                        "snacks_picker_input",
                    },
                },
            },
            {
                "folke/lazydev.nvim",
                dependencies = "Bilal2453/luvit-meta",
                opts = {
                    library = {
                        { path = "luvit-meta/library", words = { "vim%.uv" } },
                    },
                },
            },
            -- go pkgs sources for cmp
            {
                "Yu-Leo/cmp-go-pkgs",
                config = function()
                    vim.api.nvim_create_autocmd({ "LspAttach" }, {
                        pattern = { "*.go" },
                        callback = function(args)
                            require("cmp_go_pkgs").init_items(args)
                        end,
                    })
                end,
            },
        },
        event = "VeryLazy",
        config = function()
            local cmp = require("cmp")
            local lspkind = require("lspkind")
            local colorful_menu = require("colorful-menu")
            local cmp_autopairs = require("nvim-autopairs.completion.cmp")

            -- set lspkind copilot icon
            do
                lspkind.init({ symbol_map = { Copilot = "" } })
                vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })
            end

            local function has_words_before()
                if vim.api.nvim_get_option_value("buftype", { buf = 0 }) == "prompt" then
                    return false
                end
                local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                return col ~= 0
                    and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
            end

            --- @param key string
            --- @param mode string
            local function feedkey(key, mode)
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
            end

            cmp.setup({
                preselect = cmp.PreselectMode.None,
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                -- Specify the snippet engine
                snippet = {
                    expand = function(args)
                        vim.snippet.expand(args.body)
                    end,
                },
                -- Completion source
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "copilot" },
                    { name = "snippets" },
                    { name = "lazydev" },
                    { name = "go_pkgs" },
                }, {
                    { name = "async_path" },
                    { name = "buffer" },
                    { name = "calc" },
                }, {
                    { name = "git" },
                    { name = "rg" },
                }),

                -- Shortcut settings
                mapping = {
                    -- Completion appears
                    ["<A-.>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
                    -- Cancel
                    ["<A-,>"] = cmp.mapping({ i = cmp.mapping.abort(), c = cmp.mapping.close() }),
                    -- prev
                    ["<C-k>"] = function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        else
                            fallback()
                        end
                    end,
                    -- prev
                    ["<C-p>"] = function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        else
                            fallback()
                        end
                    end,
                    -- Next
                    ["<C-j>"] = function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        else
                            fallback()
                        end
                    end,
                    -- Next
                    ["<C-n>"] = function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        else
                            fallback()
                        end
                    end,
                    -- confirm
                    ["<CR>"] = cmp.mapping({
                        i = function(fallback)
                            if cmp.visible() and cmp.get_active_entry() then
                                cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
                            else
                                fallback()
                            end
                        end,
                        s = cmp.mapping.confirm({ select = true }),
                        c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
                    }),
                    -- super tab
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                        elseif vim.snippet.active({ direction = 1 }) then
                            vim.snippet.jump(1)
                            -- feedkey("<cmd>lua vim.snippet.jump(1)<CR>", "")
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    -- shift super tab
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
                        elseif vim.snippet.active({ direction = -1 }) then
                            vim.snippet.jump(-1)
                            -- feedkey("<cmd>lua vim.snippet.jump(-1)<CR>", "")
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    -- Scrolling if the window has too much content
                    ["<C-u>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
                    ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
                    -- Custom code snippet to jump to next parameter
                    ["<C-l>"] = cmp.mapping(function(fallback)
                        if vim.snippet.active({ direction = 1 }) then
                            vim.snippet.jump(1)
                            -- feedkey("<cmd>lua vim.snippet.jump(1)<CR>", "")
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    -- Custom code snippet to jump to the previous parameter
                    ["<C-h>"] = cmp.mapping(function(fallback)
                        if vim.snippet.active({ direction = -1 }) then
                            vim.snippet.jump(-1)
                            -- feedkey("<cmd>lua vim.snippet.jump(-1)<CR>", "")
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                },
                -- Display type icons with lspkind-nvim
                ---@diagnostic disable-next-line: missing-fields
                formatting = {
                    fields = { "kind", "abbr", "menu" },
                    format = function(_entry, _vim_item)
                        local kind = lspkind.cmp_format({
                            mode = "symbol_text",
                        })(_entry, vim.deepcopy(_vim_item))

                        local highlights_info = colorful_menu.cmp_highlights(_entry)

                        -- if highlight_info==nil, which means missing ts parser, let's fallback to use default `vim_item.abbr`.
                        -- What this plugin offers is two fields: `vim_item.abbr_hl_group` and `vim_item.abbr`.
                        if highlights_info ~= nil then
                            _vim_item.abbr_hl_group = highlights_info.highlights
                            _vim_item.abbr = highlights_info.text
                        end
                        local strings = vim.split(kind.kind, "%s", { trimempty = true })
                        _vim_item.kind = (strings[1] or "")
                        _vim_item.menu = ""

                        return _vim_item
                    end,
                },
            })

            cmp.setup.cmdline(":", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = "cmdline" },
                }, {
                    { name = "async_path" },
                }),
                ---@diagnostic disable-next-line: missing-fields
                formatting = {
                    -- kind is icon, abbr is completion name, menu is [Function]
                    fields = { "abbr", "menu" },
                },
            })

            cmp.setup.cmdline({ "/", "?" }, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = "nvim_lsp_document_symbol" },
                }, {
                    { name = "buffer" },
                }),
                ---@diagnostic disable-next-line: missing-fields
                formatting = {
                    -- kind is icon, abbr is completion name, menu is [Function]
                    fields = { "abbr", "menu" },
                },
            })

            cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
        end,
    },
}
