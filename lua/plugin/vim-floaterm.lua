vim.g.floaterm_width = 0.85
vim.g.floaterm_height = 0.8

__key_bind("n", "ft", "<CMD>FloatermNew<CR>")
__key_bind("t", "ft", "<CMD>FloatermNew<CR>")
__key_bind("n", "fj", "<CMD>FloatermPrev<CR>")
__key_bind("t", "fj", "<CMD>FloatermPrev<CR>")
__key_bind("n", "fk", "<CMD>FloatermNext<CR>")
__key_bind("t", "fk", "<CMD>FloatermNext<CR>")
__key_bind("n", "fs", "<CMD>FloatermToggle<CR>")
__key_bind("t", "fs", "<CMD>FloatermToggle<CR>")
__key_bind("n", "fc", "<CMD>FloatermKill<CR>")
__key_bind("t", "fc", "<CMD>FloatermKill<CR>")

if vim.fn.has("win32") and vim.fn.executable("gitui") == 1 then
    __key_bind("n", "fg", "<CMD>FloatermNew gitui <CR>")
elseif vim.fn.executable("lazygit") == 1 then
    __key_bind("n", "fg", "<CMD>FloatermNew lazygit <CR>")
end

if vim.fn.executable("lazydocker") == 1 then
    __key_bind("n", "fd", "<CMD>FloatermNew lazydocker <CR>")
end
