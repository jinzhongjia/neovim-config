local langs = require("langs")

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

local servers, handlers = {}, {}

for _, lang in pairs(langs) do
    table.insert(servers, lang.lsp)
    handlers[lang.lsp] = function()
        local lspconfig = require("lspconfig")
        lspconfig[lang.lsp].setup(config(lang.opt))
    end
end
return {
    require("plugins.lsp.ui"),
    {
        "williamboman/mason-lspconfig.nvim",
        event = "VeryLazy",
        dependencies = {
            { "williamboman/mason.nvim", opts = {} },
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
