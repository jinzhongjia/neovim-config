return
--- @type LangSpec
{
    lsp = "gopls",
    opt = {
        settings = {
            gopls = {
                analyses = {
                    -- 变量命名规范检查
                    ST1003 = false,
                    -- 检查未使用的参数
                    unusedparams = true,
                    -- 检查变量遮蔽问题
                    shadow = false,
                    -- nil 指针检查
                    nilness = true,
                    -- 未使用的写入操作检查
                    unusedwrite = true,
                    -- 检查是否可以使用更具体的类型替代 interface{}
                    useany = false,
                    -- 简化复合字面量
                    simplifycompositelit = true,
                    -- 简化 range 语句
                    simplifyrange = true,
                    -- 检查未声明的名称
                    undeclaredname = true,
                    -- 检查 bool 表达式简化
                    bools = true,
                    -- 检查复合类型简化
                    composites = true,
                },

                -- 代码完成和导入设置
                usePlaceholders = true,
                completeUnimported = true,
                staticcheck = true,

                -- 代码模板设置
                templateExtensions = { ".tmpl", ".html" },

                -- 代码镜头功能
                codelenses = {
                    gc_details = true,
                    regenerate_cgo = true,
                    generate = true,
                    test = true,
                    tidy = true,
                    upgrade_dependency = true,
                    vendor = true,
                },

                -- 语义标记
                semanticTokens = true,

                -- 代码提示设置
                hints = {
                    assignVariableTypes = true,
                    compositeLiteralFields = true,
                    compositeLiteralTypes = true,
                    constantValues = true,
                    functionTypeParameters = true,
                    parameterNames = true,
                    rangeVariableTypes = true,
                },

                -- 格式化设置（使用 gofumpt）
                gofumpt = true,
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
                    filter_main_entrance = false,
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
                "jinzhongjia/nvim-dap", -- (optional) only if you use `gopher.dap`
            },
            opts = {},
        },
        {
            "edolphin-ydf/goimpl.nvim",
            enabled = false,
            event = "VeryLazy",
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
