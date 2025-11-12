--- @type LazySpec
local M = {

    {
        "m-demare/hlargs.nvim",
        enabled = true,
        event = "LspAttach", -- LSP 加载时触发
        config = function()
            require("hlargs").setup()
            vim.api.nvim_create_augroup("LspAttach_hlargs", { clear = true })
            vim.api.nvim_create_autocmd("LspAttach", {
                group = "LspAttach_hlargs",
                callback = function(args)
                    if not (args.data and args.data.client_id) then
                        return
                    end

                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    local caps = client.server_capabilities
                    if caps.semanticTokensProvider and caps.semanticTokensProvider.full then
                        require("hlargs").disable_buf(args.buf)
                    end
                end,
            })
        end,
    },
    {
        "Wansmer/treesj",
        -- 按键触发即可
        keys = { "<space>m", "<space>j", "<space>s" },
        dependencies = { "nvim-treesitter/nvim-treesitter" }, -- if you install parsers with `nvim-treesitter`
        opts = {},
    },
    {
        "ckolkey/ts-node-action",
        dependencies = { "nvim-treesitter" },
        event = { "BufReadPost", "BufNewFile" }, -- 编辑文件时加载
        opts = {},
        keys = {
            {
                "K",
                function()
                    require("ts-node-action").node_action()
                end,
                desc = "Trigger Node Action",
            },
        },
        config = function(_, opts)
            require("ts-node-action").setup(opts)
        end,
    },
    {
        "catgoose/nvim-colorizer.lua",
        event = { "BufReadPost", "BufNewFile" }, -- 打开文件时加载
        opts = {
            filetypes = {
                "css",
                "javascript",
                "html",
            },
        },
    },
    {
        "chrisgrieser/nvim-rip-substitute",
        event = "VeryLazy",
        cmd = "RipSubstitute",
        opts = {},
        keys = {
            {
                "<leader>rs",
                function()
                    require("rip-substitute").sub()
                end,
                mode = { "n", "x" },
                desc = "rip substitute",
            },
        },
    },
    {
        "echasnovski/mini.move",
        version = "*",
        -- 按键触发时才需要,通过 keys 定义
        keys = {
            { "<M-h>", mode = { "n", "v" } },
            { "<M-j>", mode = { "n", "v" } },
            { "<M-k>", mode = { "n", "v" } },
            { "<M-l>", mode = { "n", "v" } },
        },
        opts = {},
    },
    {
        "kylechui/nvim-surround",
        version = "*", -- Use for stability; omit to use `main` branch for the latest features
        event = { "BufReadPost", "BufNewFile" }, -- 编辑文件时加载
        opts = {},
    },
    {
        "mcauley-penney/visual-whitespace.nvim",
        event = "ModeChanged", -- 模式切换时加载(进入 visual 模式)
        config = true,
    },
}

-- all plugins
__arr_concat(M, require("plugins.edit.comment"))
__arr_concat(M, require("plugins.edit.complete"))
__arr_concat(M, require("plugins.edit.fold"))
__arr_concat(M, require("plugins.edit.format"))
__arr_concat(M, require("plugins.edit.indent"))
__arr_concat(M, require("plugins.edit.lint"))
__arr_concat(M, require("plugins.edit.outline"))
__arr_concat(M, require("plugins.edit.search"))
__arr_concat(M, require("plugins.edit.snippet"))
__arr_concat(M, require("plugins.edit.debug"))

return M
