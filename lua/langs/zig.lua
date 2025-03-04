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
            build = ":ZigLamp build",
            dependencies = {
                "nvim-lua/plenary.nvim",
                "neovim/nvim-lspconfig",
            },
            dev = true,
            init = function()
                vim.g.zig_lamp_zls_auto_install = true
            end,
        },
    },
}
