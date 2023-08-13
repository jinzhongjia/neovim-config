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
        on_attach = function(client, bufnr)
            -- Disable the formatting function and leave it to a special plug-in plug-in for processing
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false

            local function buf_set_keymap(...)
                vim.api.nvim_buf_set_keymap(bufnr, ...)
            end

            -- Bind shortcut keys
            require("plugin.mason.lsp.keybind").mapLSP(buf_set_keymap)
        end,
    }

    return opt
end

return default_confit_builder
