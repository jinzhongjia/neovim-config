local status, toggleterm = pcall(require, "toggleterm")
if not status then
    vim.notify("not found toggleterm")
    return
end

toggleterm.setup({
    size = function(term)
        if term.direction == "horizontal" then
            return 15
        elseif term.direction == "vertical" then
            return vim.o.columns * 0.4
        end
    end,
    autochdir = true,
})


-- Terminal related
__key_bind("n", "<leader>t", "<CMD>ToggleTerm direction=horizontal<CR>")
-- tool.map("t", "<leader>t", "<CMD>ToggleTerm direction=horizontal<CR>")
__key_bind("n", "<leader>vt", "<CMD>ToggleTerm direction=vertical<CR>")
-- tool.map("t", "<leader>vt", "<CMD>ToggleTerm direction=vertical<CR>")
