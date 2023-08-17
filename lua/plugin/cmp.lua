local status_cmp, cmp = pcall(require, "cmp")
if not status_cmp then
    vim.notify("not found cmp")
    return
end

-- lspkind
local status_lspkind, lspkind = pcall(require, "lspkind")
if not status_lspkind then
    vim.notify("not found lspkind")
    return
end

-- autopairs
local status_npairs, npairs = pcall(require, "nvim-autopairs")
if not status_npairs then
    vim.notify("not found nvim-autopairs")
    return
end

local Rule = require("nvim-autopairs.rule")

npairs.setup({
    check_ts = true,
    ts_config = {
        lua = { "string" }, -- it will not add a pair on that treesitter node
        javascript = { "template_string" },
        java = false, -- don't check treesitter on java
    },
})

local ts_conds = require("nvim-autopairs.ts-conds")

-- press % => %% only while inside a comment or string
npairs.add_rules({
    Rule("%", "%", "lua"):with_pair(ts_conds.is_ts_node({ "string", "comment" })),
    Rule("$", "$", "lua"):with_pair(ts_conds.is_not_ts_node({ "function" })),
})

local cmp_autopairs = require("nvim-autopairs.completion.cmp")

---@diagnostic disable-next-line: redefined-local
local cmpMapping = function(cmp)
    local feedkey = function(key, mode)
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
    end

    local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
    end
    return {
        -- Completion appears
        ["<A-.>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
        -- Cancel
        ["<A-,>"] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
        }),
        -- Prev
        ["<C-k>"] = cmp.mapping.select_prev_item(),
        -- Next
        ["<C-j>"] = cmp.mapping.select_next_item(),
        -- confirm
        ["<CR>"] = cmp.mapping.confirm({
            select = true,
            behavior = cmp.ConfirmBehavior.Replace,
        }),
        -- Scrolling if the window has too much content
        ["<C-u>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
        ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
        -- Custom code snippet to jump to next parameter
        ["<C-l>"] = cmp.mapping(function(_)
            if vim.fn["vsnip#available"](1) == 1 then
                feedkey("<Plug>(vsnip-expand-or-jump)", "")
            end
        end, { "i", "s" }),

        -- Custom code snippet to jump to the previous parameter
        ["<C-h>"] = cmp.mapping(function()
            if vim.fn["vsnip#jumpable"](-1) == 1 then
                feedkey("<Plug>(vsnip-jump-prev)", "")
            end
        end, { "i", "s" }),

        -- Super Tab
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif vim.fn["vsnip#available"](1) == 1 then
                feedkey("<Plug>(vsnip-expand-or-jump)", "")
            elseif has_words_before() then
                cmp.complete()
            else
                fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
            end
        end, { "i", "s" }),

        ["<S-Tab>"] = cmp.mapping(function()
            if cmp.visible() then
                cmp.select_prev_item()
            elseif vim.fn["vsnip#jumpable"](-1) == 1 then
                feedkey("<Plug>(vsnip-jump-prev)", "")
            end
        end, { "i", "s" }),
        -- end of super Tab
    }
end

---@diagnostic disable-next-line: missing-fields
cmp.setup({
    window = {
        ---@diagnostic disable-next-line: missing-fields
        completion = { -- rounded border; thin-style scrollbar
            border = "rounded",
            ---@diagnostic disable-next-line: assign-type-mismatch
            scrollbar = "║",
        },
        ---@diagnostic disable-next-line: missing-fields
        documentation = { -- no border; native-style scrollbar
            border = "rounded",
            ---@diagnostic disable-next-line: assign-type-mismatch
            scrollbar = "",
            -- other options
        },
    },
    -- Specify the snippet engine
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
        end,
    },
    -- Completion source
    sources = cmp.config.sources({
        { name = "nvim_lsp" },

        { name = "vsnip" },

        -- document-symbol
        { name = "nvim_lsp_document_symbol" },

        -- signature-help
        { name = "nvim_lsp_signature_help" },

        { name = "async_path" },

        { name = "rg" },

        -- For luasnip users.
        -- { name = 'luasnip' },
    }, { { name = "buffer" } }),

    -- Shortcut settings
    mapping = cmpMapping(cmp),
    -- Display type icons with lspkind-nvim
    ---@diagnostic disable-next-line: missing-fields
    formatting = {
        format = lspkind.cmp_format({
            mode = "symbol_text",
            --mode = 'symbol', -- show only symbol annotations

            maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
            -- The function below will be called before any actual modifications from lspkind
            -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
            before = function(entry, vim_item)
                -- Source Displays the source of the hint
                vim_item.menu = "[" .. string.upper(entry.source.name) .. "]"
                return vim_item
            end,
        }),
    },
})

cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = "async_path" },
    }, {
        { name = "cmdline" },
    }),
})

cmp.setup.cmdline({ "/", "?" }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = "buffer" },
    },
})

cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
