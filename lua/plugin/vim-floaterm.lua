local tool = require("tool")
local map = tool.map

vim.g.floaterm_width = 0.85
vim.g.floaterm_height = 0.8

map("n", "ft", "<CMD>FloatermNew<CR>")
map("t", "ft", "<CMD>FloatermNew<CR>")
map("n", "fj", "<CMD>FloatermPrev<CR>")
map("t", "fj", "<CMD>FloatermPrev<CR>")
map("n", "fk", "<CMD>FloatermNext<CR>")
map("t", "fk", "<CMD>FloatermNext<CR>")
map("n", "fs", "<CMD>FloatermToggle<CR>")
map("t", "fs", "<CMD>FloatermToggle<CR>")
map("n", "fc", "<CMD>FloatermKill<CR>")
map("t", "fc", "<CMD>FloatermKill<CR>")

if vim.fn.has("win32") and vim.fn.executable("gitui") == 1 then
    map("n", "fg", "<CMD>FloatermNew gitui <CR>")
elseif vim.fn.executable("lazygit") == 1 then
    map("n", "fg", "<CMD>FloatermNew lazygit <CR>")
end

if vim.fn.executable("lazydocker") == 1 then
    map("n", "fd", "<CMD>FloatermNew lazydocker <CR>")
end
