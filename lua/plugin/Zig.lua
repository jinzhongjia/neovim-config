local status, zig = pcall(require, "Zig")
if not status then
    vim.notify("not found zig")
    return
end

zig.setup({
    zls = {
        web_install = {
            version = "latestTagged",
        },
        lspconfig_opt = {
            on_attach = function(_, bufnr)
                require("plugin.lspconfig.keybind").mapLSP(bufnr)
            end,
        },
        enable_lspconfig = true,
    },
})
