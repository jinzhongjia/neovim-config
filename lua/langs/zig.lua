return
--- @type LangSpec
{
    -- lsp = "zls",
    opt = nil,
    others = {},
    before_set = nil,
    after_set = nil,
    plugins = {
        {
            "jinzhongjia/zig-lamp",
            event = "VeryLazy",
            dependencies = {
                "nvim-lua/plenary.nvim",
                "MunifTanjim/nui.nvim",
            },
        },
    },
}
