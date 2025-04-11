if vim.g.vscode then
    return
end
-- reload buffer on focus
vim.api.nvim_create_autocmd({
    "FocusGained",
    "BufEnter",
    "CursorHold",
}, {
    desc = "Reload buffer on focus",
    callback = function()
        if vim.fn.getcmdwintype() == "" then
            vim.cmd("checktime")
        end
    end,
})
