return
--- @type LazySpec
{
    -- LSP 核心与服务器默认配置
    {
        "neovim/nvim-lspconfig",
        event = "VeryLazy",
        dependencies = {
            "mason-org/mason.nvim",
            "mason-org/mason-lspconfig.nvim",
        },
        config = function()
            -- Mason 和 mason-lspconfig 设置
            require("mason").setup()
            require("mason-lspconfig").setup({
                -- 在这里列出您希望 Mason 自动安装和管理的 LSP 服务器
                -- mason-lspconfig 会确保它们被自动启用
                ensure_installed = {
                    "gopls",
                    "basedpyright",
                    "vtsls",
                    "lua_ls",
                    "buf_ls",
                    "dockerls",
                    "protols",
                    "clangd",
                    "cssls",
                    "html",
                    "rust_analyzer",
                    "yamlls",
                    "golangci_lint_ls",
                },
                -- 您也可以设置为 automatic_enable = false，然后手动调用 vim.lsp.enable()
                automatic_enable = true,
            })
        end,
    },
}
