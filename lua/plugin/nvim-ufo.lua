local status, nvim_ufo = pcall(require, "ufo")
if not status then
    vim.notify("not found ufo")
    return
end

nvim_ufo.setup({
    provider_selector = function(bufnr, filetype, buftype)
        return { "treesitter", "indent" }
    end,
})

vim.keymap.set("n", "zR", function()
    nvim_ufo.openAllFolds()
end)
vim.keymap.set("n", "zM", function()
    nvim_ufo.closeAllFolds()
end)
