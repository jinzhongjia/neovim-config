--- @param opt table?
local function config(opt)
    local capabilities = require("blink.cmp").get_lsp_capabilities()

    -- for ufo
    capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
    }
    local default_config = {
        capabilities = capabilities,
        flags = { debounce_text_changes = 150 },
        --- @param client vim.lsp.Client
        on_attach = function(client, _)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
        end,
    }
    if opt == nil then
        return default_config
    end
    return vim.tbl_deep_extend("force", default_config, opt)
end

-- lang servers, server handlers, other tools
local servers, handlers, others = {}, {}, {}

--- @type LazySpec[]
local lang_plugins = {}

---@diagnostic disable-next-line: param-type-mismatch
local langs_path = vim.fs.normalize(vim.fs.joinpath(vim.fn.stdpath("config"), "lua", "langs"))
for file, _ in vim.fs.dir(langs_path) do
    local file_name = vim.fn.fnamemodify(file, ":t:r")
    --- @type LangSpec
    local lang = require("langs." .. file_name)

    -- set lang's lspconfig and install lsp
    if lang.lsp then
        table.insert(servers, lang.lsp)

        handlers[lang.lsp] = function()
            local lspconfig = require("lspconfig")
            if lang.before_set then
                lang.before_set()
            end
            if lang.opt then
                lspconfig[lang.lsp].setup(config(lang.opt))
            end
            if lang.after_set then
                lang.after_set()
            end
        end
    end

    -- install other tools
    others = __tbl_merge(others, lang.others)
    -- install lint tools
    others = __tbl_merge(others, lang.lint)
    -- install format tools
    others = __tbl_merge(others, lang.format)

    -- add lang's plugins
    __arr_concat(lang_plugins, lang.plugins)
end

--- @type LazySpec
local M = {
    {
        "jinzhongjia/mason-lspconfig.nvim",
        branch = "protols",
        event = "VeryLazy",
        dependencies = {
            {
                "williamboman/mason.nvim",
                config = function()
                    local mason = require("mason")
                    local mason_registry = require("mason-registry")

                    local ensure_installed = function()
                        for _, name in pairs(others) do
                            if not mason_registry.is_installed(name) then
                                local package = mason_registry.get_package(name)
                                package:install()
                            end
                        end
                    end

                    mason.setup()

                    mason_registry.refresh(vim.schedule_wrap(ensure_installed))
                end,
            },
            { "neovim/nvim-lspconfig" },
            { "saghen/blink.cmp" },
        },
        opts = {
            ensure_installed = servers,
            handlers = handlers,
        },
    },
}

-- add ui plugins
--- @diagnostic disable-next-line: param-type-mismatch
__arr_concat(M, require("plugins.lsp.ui"))

-- add lang's plugins
--- @diagnostic disable-next-line: param-type-mismatch
__arr_concat(M, lang_plugins)

return M
