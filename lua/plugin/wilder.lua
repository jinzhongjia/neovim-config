local status, wilder = pcall(require, "wilder")
if not status then
    vim.notify("not found windows")
    return
end

wilder.setup({ modes = { ':', '/', '?' } })

wilder.set_option('renderer', wilder.popupmenu_renderer({
    pumblend = 20,
}))
