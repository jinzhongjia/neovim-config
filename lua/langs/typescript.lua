return
--- @type LangSpec
{
    lsp = "ts_ls",
    opt = {},
    others = { "prettierd" },
    before_set = nil,
    after_set = nil,
    lint = { "ts-standard" },
    plugins = {
        {
            "dmmulroy/tsc.nvim",
            event = "VeryLazy",
            opts = {},
        },
    },
}
