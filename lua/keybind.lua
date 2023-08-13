local tool = require("tool")
local map = tool.map
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Cancel s default function
map("n", "s", "")

-- Windows split screen shortcuts
map("n", "sv", ":vsp<CR>")
map("n", "sh", ":sp<CR>")
-- Close current
map("n", "sc", "<C-w>c")
-- Close other
map("n", "so", "<C-w>o")

-- Alt + hjkl jump between windows
map("n", "wh", "<C-w>h")
map("n", "wj", "<C-w>j")
map("n", "wk", "<C-w>k")
map("n", "wl", "<C-w>l")

-- Left and right proportional control
map("n", "<C-Left>", ":vertical resize -2<CR>")
map("n", "<C-Right>", ":vertical resize +2<CR>")
map("n", "s,", ":vertical resize -20<CR>")
map("n", "s.", ":vertical resize +20<CR>")
-- Up and down ratio
map("n", "sj", ":resize +10<CR>")
map("n", "sk", ":resize -10<CR>")
map("n", "<C-Down>", ":resize +2<CR>")
map("n", "<C-Up>", ":resize -2<CR>")
-- Ratio
map("n", "s=", "<C-w>=")

-- Terminal related
map("n", "<leader>t", ":sp | terminal<CR>")
map("n", "<leader>vt", ":vsp | terminal<CR>")

-- Indent code in visual mode
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Move selected text up and down
map("v", "J", ":move '>+1<CR>gv-gv")
map("v", "K", ":move '<-2<CR>gv-gv")

-- Scroll up and down
map("n", "<C-j>", "3j")
map("n", "<C-k>", "3k")
-- Ctrl u / ctrl + d move only 9 lines, half screen by default
map("n", "<C-u>", "7k")
map("n", "<C-d>", "7j")

-- Exit
map("n", "q", ":q<CR>")
map("n", "qq", ":q!<CR>")
map("n", "Q", ":qa!<CR>")

-- ctrl+s save
map("n", "<C-s>", ":w<CR>")
map("i", "<C-s>", "<ESC>:w<CR>")

-- Configure Copy Shortcuts
map("v", "<C-c>", '"+y')       -- copy
map("v", "<C-x>", '"+d')       -- cut
-- map("n", "<C-v>", '"+p') -- paste from system clipboard
map("i", "<C-v>", '<ESC>"+pa') -- paste from system clipboard
