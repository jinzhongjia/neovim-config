local status, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not status then
    vim.notify("not found cmp_nvim_lsp")
    return
end

local capabilities = cmp_nvim_lsp.default_capabilities()

-- for ufo
capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
}

local function default_confit_builder()
    -- local init_config = true
    local opt = {
        capabilities = capabilities,
        flags = {
            debounce_text_changes = 150,
        },
        --- @param client vim.lsp.Client
        ---@param bufnr integer
        on_attach = function(client, bufnr)
            -- Disable the formatting function and leave it to a special plug-in plug-in for processing
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false

            -- Bind shortcut keys
            require("plugin.lspconfig.keybind").mapLSP(bufnr)
        end,
    }

    return opt
end

return default_confit_builder
