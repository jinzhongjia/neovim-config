return
--- @type LazySpec
{
    {
        "SmiteshP/nvim-navic",
        event = "LspAttach",
        opts = {
            highlight = true,
            lsp = {
                auto_attach = true, -- 自动 attach 到支持 documentSymbol 的 LSP
            },
            separator = " › ",
            depth_limit = 5,
            lazy_update_context = true, -- 性能优化
        },
    },
}

