local status, fidget = pcall(require, "fidget")
if not status then
    vim.notify("not found fidget")
    return
end

fidget.setup({
    sources = { -- Sources to configure
        ["null-ls"] = {
            ignore = true,
        },
    },
})
