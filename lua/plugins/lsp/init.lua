local M = {
    {
        "mason-org/mason-lspconfig.nvim",
        event = "VeryLazy",
        dependencies = {
            {
                "mason-org/mason.nvim",
                config = function()
                    local mason = require("mason")
                    local mason_registry = require("mason-registry")

                    local ensure_installed = function(pkgs)
                        for _, pkg in pairs(pkgs) do
                            if type(pkg) == "string" then
                                if not mason_registry.is_installed(pkg) then
                                    local package = mason_registry.get_package(pkg)
                                    package:install()
                                end
                            elseif type(pkg) == "table" then
                                if pkg.name and not mason_registry.is_installed(pkg.name) then
                                    local package = mason_registry.get_package(pkg.name)
                                    package:install({ version = pkg.version })
                                end
                            end
                        end
                    end

                    mason.setup()

                    -- 收集所有需要安装的工具
                    local others = {}
                    local langs_path = vim.fs.normalize(vim.fs.joinpath(vim.fn.stdpath("config"), "lua", "langs"))
                    for file, _ in vim.fs.dir(langs_path) do
                        local file_name = vim.fn.fnamemodify(file, ":t:r")
                        local lang = require("langs." .. file_name)
                        others = __tbl_merge(others, lang.others)
                        others = __tbl_merge(others, lang.lint)
                        others = __tbl_merge(others, lang.format)
                    end

                    -- 安装工具
                    mason_registry.refresh(vim.schedule_wrap(function()
                        ensure_installed(others)
                    end))
                end,
            },
            { "neovim/nvim-lspconfig" },
            { "saghen/blink.cmp" },
        },
        config = function()
            -- 使用新的 vim.lsp.config API 配置语言服务器
            -- 首先设置所有 LSP 的默认配置
            vim.lsp.config("*", {
                capabilities = (function()
                    local capabilities = require("blink.cmp").get_lsp_capabilities()
                    capabilities.textDocument.foldingRange = {
                        dynamicRegistration = false,
                        lineFoldingOnly = true,
                    }
                    return capabilities
                end)(),
                flags = { debounce_text_changes = 150 },
                on_attach = function(client, _)
                    client.server_capabilities.documentFormattingProvider = false
                    client.server_capabilities.documentRangeFormattingProvider = false
                end,
            })

            local mason_lspconfig = require("mason-lspconfig")
            local mappings = mason_lspconfig.get_mappings()
            local supported_set = mappings.package_to_lspconfig
            
            -- 也包含直接的 lspconfig 名称映射
            for lspconfig_name, _ in pairs(mappings.lspconfig_to_package) do
                supported_set[lspconfig_name] = true
            end

            local langs_path = vim.fs.normalize(vim.fs.joinpath(vim.fn.stdpath("config"), "lua", "langs"))
            local servers = {}

            for file, _ in vim.fs.dir(langs_path) do
                local file_name = vim.fn.fnamemodify(file, ":t:r")
                local lang = require("langs." .. file_name)

                if lang.lsp and supported_set[lang.lsp] then
                    table.insert(servers, lang.lsp)

                    -- 为每个语言服务器应用特定配置
                    vim.lsp.config(lang.lsp, lang.opt or {})

                    -- 应用任何before_set函数
                    if lang.before_set then
                        lang.before_set()
                    end

                    -- 启用语言服务器
                    vim.lsp.enable(lang.lsp)

                    -- 应用任何after_set函数
                    if lang.after_set then
                        lang.after_set()
                    end
                end
            end

            -- 安装所有语言服务器
            mason_lspconfig.setup({
                ensure_installed = servers,
                automatic_enable = false,
            })
        end,
    },
}

-- 添加UI插件
__arr_concat(M, require("plugins.lsp.ui"))

-- 添加语言特定插件
local langs_path = vim.fs.normalize(vim.fs.joinpath(vim.fn.stdpath("config"), "lua", "langs"))
for file, _ in vim.fs.dir(langs_path) do
    local file_name = vim.fn.fnamemodify(file, ":t:r")
    local lang = require("langs." .. file_name)
    __arr_concat(M, lang.plugins)
end

return M
