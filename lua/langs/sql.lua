return
--- @type LangSpec
{
    plugins = {
        {
            "nanotee/sqls.nvim",
            event = "VeryLazy",
            config = function()
                require("lspconfig").sqls.setup({
                    on_attach = function(client, bufnr)
                        require("sqls").on_attach(client, bufnr)
                    end,
                })
            end,
        },
    },
}
