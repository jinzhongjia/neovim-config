local tool = require("tool")
local map = tool.map

vim.g.floaterm_width = 0.8
vim.g.floaterm_height = 0.8

map("n", "ft", ":FloatermNew<CR>")
map("t", "ft", "<C-\\><C-n>:FloatermNew<CR>")
map("n", "fj", ":FloatermPrev<CR>")
map("t", "fj", "<C-\\><C-n>:FloatermPrev<CR>")
map("n", "fk", ":FloatermNext<CR>")
map("t", "fk", "<C-\\><C-n>:FloatermNext<CR>")
map("n", "fs", ":FloatermToggle<CR>")
map("t", "fs", "<C-\\><C-n>:FloatermToggle<CR>")
map("n", "fc", ":FloatermKill<CR>")
map("t", "fc", "<C-\\><C-n>:FloatermKill<CR>")

if vim.fn.executable("lazygit") then
    map("n", "fg", ":FloatermNew lazygit <CR>")
end

if vim.fn.executable("lazydocker") then
    map("n", "fd", ":FloatermNew lazydocker <CR>")
end
