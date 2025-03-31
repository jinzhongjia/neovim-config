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
                require("dap-go").setup({
                    delve = {
                        initialize_timeout_sec = false,
                    },
                })
            end,
        },
        {
            "olexsmir/gopher.nvim",
            event = "VeryLazy",
            enabled = false,
            -- branch = "develop", -- if you want develop branch
            -- keep in mind, it might break everything
            dependencies = {
                "nvim-lua/plenary.nvim",
                "nvim-treesitter/nvim-treesitter",
                "mfussenegger/nvim-dap", -- (optional) only if you use `gopher.dap`
            },
            opts = {},
        },
        {
            "edolphin-ydf/goimpl.nvim",
            event = "VeryLazy",
            dependencies = {
                { "nvim-lua/plenary.nvim" },
                { "nvim-lua/popup.nvim" },
                { "nvim-telescope/telescope.nvim" },
                { "nvim-treesitter/nvim-treesitter" },
            },
            config = function()
                require("telescope").load_extension("goimpl")
            end,
        },
    },
}
