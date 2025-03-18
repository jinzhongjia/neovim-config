return
--- @type LangSpec
{
    lsp = "gopls",
    opt = {
        settings = {
            gopls = {
                hints = {
                    assignVariableTypes = true,
                    compositeLiteralFields = true,
                    compositeLiteralTypes = true,
                    constantValues = true,
                    functionTypeParameters = true,
                    parameterNames = true,
                    rangeVariableTypes = true,
                },
            },
        },
    },
    lint = {},
    others = { "gofumpt", "goimports", "golines", "goimports-reviser", "delve" },
    before_set = nil,
    after_set = nil,
    plugins = {
        {
            "jinzhongjia/nvim-dap-go",
            event = "VeryLazy",
            dev = true,
            config = function()
                require("dap-go").setup()
            end,
        },
        {
            "maxandron/goplements.nvim",
            event = "VeryLazy",
            opts = {},
        },
        {
            "edolphin-ydf/goimpl.nvim",
            dependencies = {
                { "nvim-lua/plenary.nvim" },
                { "nvim-telescope/telescope.nvim" },
                { "nvim-treesitter/nvim-treesitter" },
            },
            config = function()
                require("telescope").load_extension("goimpl")
            end,
        },
    },
}
