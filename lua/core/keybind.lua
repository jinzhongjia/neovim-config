vim.g.mapleader = " "
vim.g.maplocalleader = " "


-- Windows split screen shortcuts
__key_bind("n", "<leader>sv", "<CMD>vsp<CR>")
__key_bind("n", "<leader>sh", "<CMD>sp<CR>")
-- Close current
__key_bind("n", "<leader>sc", "<C-w>c")
-- Close other
__key_bind("n", "<leader>so", "<C-w>o")

-- Alt + hjkl jump between windows
__key_bind("n", "wh", "<C-w>h")
__key_bind("n", "wj", "<C-w>j")
__key_bind("n", "wk", "<C-w>k")
__key_bind("n", "wl", "<C-w>l")

-- Left and right proportional control
__key_bind("n", "<C-Left>", "<CMD>vertical resize -2<CR>")
__key_bind("n", "<C-Right>", "<CMD>vertical resize +2<CR>")
__key_bind("n", "<leader>s,", "<CMD>vertical resize -2<CR>")
__key_bind("n", "<leader>s.", "<CMD>vertical resize +2<CR>")
-- Up and down ratio
__key_bind("n", "<leader>sj", "<CMD>resize +2<CR>")
__key_bind("n", "<leader>sk", "<CMD>resize -2<CR>")
__key_bind("n", "<C-Down>", "<CMD>resize +2<CR>")
__key_bind("n", "<C-Up>", "<CMD>resize -2<CR>")
-- Ratio
__key_bind("n", "<leader>s=", "<C-w>=")

-- Indent code in visual mode
__key_bind("v", "<", "<gv")
__key_bind("v", ">", ">gv")

-- Move selected text up and down
__key_bind("v", "J", "<CMD>move '>+1<CR>gv-gv")
__key_bind("v", "K", "<CMD>move '<-2<CR>gv-gv")
__key_bind("n", "<C-s>", "<CMD>w<CR>")
__key_bind("i", "<C-s>", "<ESC><CMD>w<CR>")

-- Configure Copy Shortcuts
__key_bind("v", "<C-c>", '"+y') -- copy
__key_bind("v", "<C-x>", '"+d') -- cut
-- map("n", "<C-v>", '"+p') -- paste from system clipboard
__key_bind("i", "<C-v>", '<ESC>"+pa') -- paste from system clipboard
