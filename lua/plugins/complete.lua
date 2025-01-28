return
--- @type LazySpec
{
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-calc",
            "hrsh7th/cmp-nvim-lsp-document-symbol",
            {
                "zbirenbaum/copilot-cmp",
                dependencies = {
                    "zbirenbaum/copilot.lua",
                    opts = {
                        suggestion = { enabled = false },
                        panel = { enabled = false },
                    },
                },
                opts = {},
            },
            -- async path
            {
                "FelipeLema/cmp-async-path",
                url = "https://codeberg.org/FelipeLema/cmp-async-path",
            },
            { "garymjr/nvim-snippets", opts = { friendly_snippets = true } },
            --- ui denpendences
            { "onsails/lspkind-nvim" },
            { "xzbdmw/colorful-menu.nvim", opts = {} },
            --- autopairs
            { "windwp/nvim-autopairs", opts = {} },
            { "rafamadriz/friendly-snippets" },
            {
                "folke/lazydev.nvim",
                dependencies = "Bilal2453/luvit-meta",
                opts = {
                    library = {
                        { path = "luvit-meta/library", words = { "vim%.uv" } },
                    },
                },
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
                lspkind.init({
                    symbol_map = {
                        Copilot = "",
                    },
                })
                vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })
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
                }, {
                    { name = "async_path" },
                    { name = "buffer" },
                    { name = "calc" },
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
                        local has_words_before = function()
                            if vim.api.nvim_get_option_value("buftype", { buf = 0 }) == "prompt" then
                                return false
                            end
                            local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                            return col ~= 0
                                and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$")
                                    == nil
                        end

                        --- @param key string
                        --- @param mode string
                        local feedkey = function(key, mode)
                            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
                        end

                        if cmp.visible() and has_words_before() then
                            cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                        elseif vim.snippet.active({ direction = 1 }) then
                            feedkey("<cmd>lua vim.snippet.jump(1)<CR>", "")
                        elseif has_words_before() then
                            cmp.complete()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    -- shift super tab
                    ["<S-Tab>"] = cmp.mapping(function(_)
                        local feedkey = function(key, mode)
                            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
                        end

                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif vim.snippet.active({ direction = -1 }) then
                            feedkey("<cmd>lua vim.snippet.jump(-1)<CR>", "")
                        end
                    end, { "i", "s" }),
                    -- Scrolling if the window has too much content
                    ["<C-u>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
                    ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
                    -- Custom code snippet to jump to next parameter
                    ["<C-l>"] = cmp.mapping(function(_)
                        local feedkey = function(key, mode)
                            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
                        end
                        if vim.snippet.active({ direction = 1 }) then
                            feedkey("<cmd>lua vim.snippet.jump(1)<CR>", "")
                        end
                    end, { "i", "s" }),
                    -- Custom code snippet to jump to the previous parameter
                    ["<C-h>"] = cmp.mapping(function()
                        local feedkey = function(key, mode)
                            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
                        end
                        if vim.snippet.active({ direction = -1 }) then
                            feedkey("<cmd>lua vim.snippet.jump(-1)<CR>", "")
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
