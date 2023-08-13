local tool = require("tool")
local map = tool.map

vim.g.floaterm_width = 0.8
vim.g.floaterm_height = 0.8

map("n", "<leader>ft", ":FloatermNew<CR>")
map("t", "<leader>ft", "<C-\\><C-n>:FloatermNew<CR>")
map("n", "<leader>fj", ":FloatermPrev<CR>")
map("t", "<leader>fj", "<C-\\><C-n>:FloatermPrev<CR>")
map("n", "<leader>fk", ":FloatermNext<CR>")
map("t", "<leader>fk", "<C-\\><C-n>:FloatermNext<CR>")
map("n", "<leader>fs", ":FloatermToggle<CR>")
map("t", "<leader>fs", "<C-\\><C-n>:FloatermToggle<CR>")
map("n", "<leader>fc", ":FloatermKill<CR>")
map("t", "<leader>fc", "<C-\\><C-n>:FloatermKill<CR>")

if vim.fn.executable("lazygit") then
	map("n", "<leader>fg", ":FloatermNew lazygit <CR>")
end

if vim.fn.executable("lazydocker") then
	map("n", "<leader>fd", ":FloatermNew lazydocker <CR>")
end
