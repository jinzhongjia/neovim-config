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
            -- 为 nvim-ufo 添加 foldingRange capabilities
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities.textDocument.foldingRange = {
                dynamicRegistration = false,
                lineFoldingOnly = true,
            }
            -- 设置全局 LSP 默认配置
            vim.lsp.config("*", {
                capabilities = capabilities,
            })

            -- 镜像 nvim-lspconfig 的 bufname_valid 逻辑，阻止 LSP attach 到虚拟 buffer
            local function bufname_valid(bufname)
                if bufname:match("^/") or bufname:match("^[a-zA-Z]:") then
                    return true
                end
                if bufname:match("^zipfile://") or bufname:match("^tarfile:") then
                    return true
                end
                return false
            end

            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local buftype = vim.bo[args.buf].buftype
                    if buftype == "nofile" then
                        vim.schedule(function()
                            pcall(vim.lsp.buf_detach_client, args.buf, args.data.client_id)
                        end)
                        return true
                    end

                    local bufname = vim.api.nvim_buf_get_name(args.buf)
                    if #bufname > 0 and not bufname_valid(bufname) then
                        vim.schedule(function()
                            pcall(vim.lsp.buf_detach_client, args.buf, args.data.client_id)
                        end)
                        return true
                    end
                end,
            })

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
                    "markdown_oxide",
                    "zls",
                },
                -- 您也可以设置为 automatic_enable = false，然后手动调用 vim.lsp.enable()
                automatic_enable = true,
            })
        end,
    },
}
