local status, LspUI = pcall(require, "LspUI")
if not status then
    vim.notify("not found LspUI")
    return
end

LspUI.setup({
    inlay_hint = {
        filter = {
            -- blacklist = { "zig" },
        },
    },
})
