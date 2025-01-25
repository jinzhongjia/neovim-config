local status, aerial = pcall(require, "aerial")
if not status then
    vim.notify("not found aerial")
    return
end

aerial.setup({
    layout = {
        min_width = 20,
    },
})

__key_bind("n", "<leader>a", "<CMD>AerialToggle!<CR>")
