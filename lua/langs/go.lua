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
            "olexsmir/gopher.nvim",
            event = "VeryLazy",
            -- branch = "develop", -- if you want develop branch
            -- keep in mind, it might break everything
            dependencies = {
                "nvim-lua/plenary.nvim",
                "nvim-treesitter/nvim-treesitter",
                "mfussenegger/nvim-dap", -- (optional) only if you use `gopher.dap`
            },
            opts = {},
        },
    },
}
