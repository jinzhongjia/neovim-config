local status, zig = pcall(require, "Zig")
if not status then
    vim.notify("not found zig")
    return
end

zig.setup({
    zls = {
        lspconfig_opt = {
            on_attach = function(client, bufnr)
                require("plugin.mason.lsp.keybind").mapLSP(bufnr)
            end,
        },
    },
})
