vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 注: <leader> 前缀的快捷键已在 lua/plugins/ui.lua 的 which-key 中统一定义
-- 此文件仅定义非 <leader> 快捷键，使用 vim.keymap.set 以支持 desc

-- ===== Ctrl 快捷键：调整窗口大小 =====
vim.keymap.set("n", "<C-Left>", "<CMD>vertical resize -2<CR>", { noremap = true, silent = true, desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", "<CMD>vertical resize +2<CR>", { noremap = true, silent = true, desc = "Increase window width" })
vim.keymap.set("n", "<C-Down>", "<CMD>resize +2<CR>", { noremap = true, silent = true, desc = "Increase window height" })
vim.keymap.set("n", "<C-Up>", "<CMD>resize -2<CR>", { noremap = true, silent = true, desc = "Decrease window height" })

-- ===== Visual 模式：缩进和移动 =====
vim.keymap.set("v", "<", "<gv", { noremap = true, silent = true, desc = "Indent left (keep selection)" })
vim.keymap.set("v", ">", ">gv", { noremap = true, silent = true, desc = "Indent right (keep selection)" })
vim.keymap.set("v", "J", "<CMD>move '>+1<CR>gv-gv", { noremap = true, silent = true, desc = "Move selection down" })
vim.keymap.set("v", "K", "<CMD>move '<-2<CR>gv-gv", { noremap = true, silent = true, desc = "Move selection up" })

-- ===== 复制粘贴快捷键 =====
vim.keymap.set("v", "<C-c>", '"+y', { noremap = true, silent = true, desc = "Copy to system clipboard" })
vim.keymap.set("i", "<C-v>", '<ESC>"+pa', { noremap = true, silent = true, desc = "Paste from system clipboard" })

-- Buffer 导航快捷键已在 lua/plugins/ui.lua 中配置
-- 使用 bn (下一个) 和 bp (上一个) 进行 buffer 切换
