-- local langs = require("langs")

--- @param opt table?
local function config(opt)
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    local capabilities = cmp_nvim_lsp.default_capabilities()

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

local servers, handlers, others = {}, {}, {}

---@diagnostic disable-next-line: param-type-mismatch
local langs_path = vim.fs.normalize(vim.fs.joinpath(vim.fn.stdpath("config"), "lua", "langs"))
for file, _ in vim.fs.dir(langs_path) do
    local file_name = vim.fn.fnamemodify(file, ":t:r")
    --- @type LangSpec
    local lang = require("langs." .. file_name)
    if lang.lsp then
        table.insert(servers, lang.lsp)
        handlers[lang.lsp] = function()
            local lspconfig = require("lspconfig")
            if lang.before_set then
                lang.before_set()
            end
            lspconfig[lang.lsp].setup(config(lang.opt))
            if lang.after_set then
                lang.after_set()
            end
        end
    end

    others = __tbl_merge(others, lang.others)
    others = __tbl_merge(others, lang.lint)
    others = __tbl_merge(others, lang.format)
end

return {
    require("plugins.lsp.ui"),
    {
        "williamboman/mason-lspconfig.nvim",
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
            { "hrsh7th/cmp-nvim-lsp" },
        },
        opts = {
            automatic_installation = true,
            ensure_installed = servers,
            handlers = handlers,
        },
    },
}
