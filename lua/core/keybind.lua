vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Windows split screen shortcuts
__key_bind("n", "sv", "<CMD>vsp<CR>")
__key_bind("n", "sh", "<CMD>sp<CR>")
-- Close current
__key_bind("n", "sc", "<C-w>c")
-- Close other
__key_bind("n", "so", "<C-w>o")

-- Alt + hjkl jump between windows
__key_bind("n", "wh", "<C-w>h")
__key_bind("n", "wj", "<C-w>j")
__key_bind("n", "wk", "<C-w>k")
__key_bind("n", "wl", "<C-w>l")

-- Left and right proportional control
__key_bind("n", "<C-Left>", "<CMD>vertical resize -2<CR>")
__key_bind("n", "<C-Right>", "<CMD>vertical resize +2<CR>")
__key_bind("n", "s,", "<CMD>vertical resize -2<CR>")
__key_bind("n", "s.", "<CMD>vertical resize +2<CR>")
-- Up and down ratio
__key_bind("n", "sj", "<CMD>resize +2<CR>")
__key_bind("n", "sk", "<CMD>resize -2<CR>")
__key_bind("n", "<C-Down>", "<CMD>resize +2<CR>")
__key_bind("n", "<C-Up>", "<CMD>resize -2<CR>")
-- Ratio
__key_bind("n", "s=", "<C-w>=")

-- Indent code in visual mode
__key_bind("v", "<", "<gv")
__key_bind("v", ">", ">gv")

-- Move selected text up and down
__key_bind("v", "J", "<CMD>move '>+1<CR>gv-gv")
__key_bind("v", "K", "<CMD>move '<-2<CR>gv-gv")

-- Configure Copy Shortcuts
__key_bind("v", "<C-c>", '"+y') -- copy
__key_bind("v", "<C-x>", '"+d') -- cut
-- map("n", "<C-v>", '"+p') -- paste from system clipboard
__key_bind("i", "<C-v>", '<ESC>"+pa') -- paste from system clipboard

-- Tab 管理快捷键
__key_bind("n", "<leader>tn", "<CMD>tabnew<CR>") -- 新建 tab
__key_bind("n", "<leader>tc", "<CMD>tabclose<CR>") -- 关闭当前 tab
__key_bind("n", "<leader>to", "<CMD>tabonly<CR>") -- 关闭其他 tab
__key_bind("n", "<leader>th", "<CMD>tabprevious<CR>") -- 前一个 tab
__key_bind("n", "<leader>tl", "<CMD>tabnext<CR>") -- 后一个 tab
__key_bind("n", "<leader>t1", "<CMD>tabn 1<CR>") -- 跳转到第 1 个 tab
__key_bind("n", "<leader>t2", "<CMD>tabn 2<CR>") -- 跳转到第 2 个 tab
__key_bind("n", "<leader>t3", "<CMD>tabn 3<CR>") -- 跳转到第 3 个 tab
__key_bind("n", "<leader>t4", "<CMD>tabn 4<CR>") -- 跳转到第 4 个 tab
__key_bind("n", "<leader>t5", "<CMD>tabn 5<CR>") -- 跳转到第 5 个 tab

-- Buffer 导航快捷键已在 lua/plugins/ui.lua 中配置
-- 使用 bn (下一个) 和 bp (上一个) 进行 buffer 切换
