return
--- @type LangSpec
{
    lsp = "vtsls",
    opt = {},
    others = { "prettierd" },
    before_set = nil,
    after_set = nil,
    lint = {},
    plugins = {
        {
            "dmmulroy/tsc.nvim",
            event = "VeryLazy",
            opts = {},
        },
    },
}
