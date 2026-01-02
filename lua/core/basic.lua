local o, g = vim.o, vim.g

g.mapleader = " "
g.maplocalleader = ","

-- =====================
-- 编码设置
-- =====================
o.encoding = "utf-8" -- Neovim 内部使用的字符编码
o.fileencoding = "utf-8" -- 写入文件时使用的编码

-- =====================
-- 滚动行为
-- =====================
o.scrolloff = 5 -- 光标距离窗口顶部/底部保持 5 行距离
o.sidescroll = 5 -- 水平滚动时每次移动 5 列

-- =====================
-- 工作目录
-- =====================
o.autochdir = false -- 不自动切换工作目录到当前文件所在目录

-- =====================
-- 行号显示
-- =====================
o.number = true -- 显示绝对行号
o.relativenumber = false -- 关闭相对行号

-- =====================
-- 光标行高亮
-- =====================
o.cursorline = true -- 高亮当前光标所在行

-- =====================
-- 标记列
-- =====================
o.signcolumn = "yes" -- 始终显示标记列 (用于 git 状态、诊断图标等)

-- =====================
-- 列参考线
-- =====================
o.colorcolumn = "120" -- 在第 120 列显示参考线 (代码宽度提示)

-- =====================
-- 缩进设置
-- =====================
o.tabstop = 4 -- Tab 字符显示宽度为 4 个空格
o.softtabstop = 4 -- 编辑时 Tab 键插入的空格数
o.shiftround = true -- 缩进时对齐到 shiftwidth 的倍数
o.shiftwidth = 4 -- 自动缩进时使用 4 个空格
o.expandtab = true -- 将 Tab 转换为空格
o.autoindent = true -- 新行继承上一行的缩进
o.smartindent = true -- 智能缩进 (根据语法自动调整)

-- =====================
-- 搜索设置
-- =====================
o.ignorecase = true -- 搜索时忽略大小写
o.smartcase = true -- 如果搜索包含大写字母则区分大小写
o.hlsearch = true -- 高亮所有搜索匹配项
o.incsearch = true -- 边输入边显示搜索结果

vim.keymap.set("n", "<leader>l", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- =====================
-- 窗口分割快捷键
-- =====================
vim.keymap.set("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "Vertical split" })
vim.keymap.set("n", "<leader>sh", "<cmd>split<CR>", { desc = "Horizontal split" })
vim.keymap.set("n", "<leader>sc", "<cmd>close<CR>", { desc = "Close split" })
vim.keymap.set("n", "<leader>wh", "<C-w>h", { desc = "Switch to left window" })
vim.keymap.set("n", "<leader>wj", "<C-w>j", { desc = "Switch to below window" })
vim.keymap.set("n", "<leader>wk", "<C-w>k", { desc = "Switch to above window" })
vim.keymap.set("n", "<leader>wl", "<C-w>l", { desc = "Switch to right window" })

-- =====================
-- 命令行
-- =====================
o.cmdheight = 1 -- 命令行高度为 1 行

-- =====================
-- 文件读取
-- =====================
o.autoread = true -- 文件在外部被修改时自动重新读取

-- =====================
-- 换行与光标移动
-- =====================
o.wrap = false -- 不自动换行 (长行水平滚动显示)
o.whichwrap = "b,s,<,>,[,]" -- 允许这些键在行首/行尾时跨行移动

-- =====================
-- 缓冲区
-- =====================
o.hidden = true -- 允许隐藏未保存的缓冲区

-- =====================
-- 鼠标与剪贴板
-- =====================
o.mouse = "a" -- 在所有模式下启用鼠标支持
o.clipboard = "unnamedplus" -- 与系统剪贴板同步 (y/p 直接操作系统剪贴板)

-- =====================
-- 备份、交换文件与撤销
-- =====================
o.backup = false -- 不创建备份文件
o.writebackup = false -- 写入时不创建备份
o.swapfile = false -- 不创建交换文件 (避免 .swp 文件)
o.undofile = true -- 持久化撤销历史 (关闭文件后仍可撤销)

-- =====================
-- 超时设置
-- =====================
o.updatetime = 300 -- CursorHold 事件触发时间 (ms), 用于 LSP 诊断显示
o.timeoutlen = 500 -- 按键序列等待时间 (ms), 影响组合键识别速度

-- =====================
-- 窗口分割
-- =====================
o.splitbelow = true -- 水平分割时新窗口在下方
o.splitright = true -- 垂直分割时新窗口在右侧

-- =====================
-- 补全菜单
-- =====================
o.completeopt = "menu,menuone,noselect,noinsert" -- 补全选项: 显示菜单、单项也显示、不自动选中、不自动插入

-- =====================
-- 颜色主题
-- =====================
o.background = "dark" -- 使用深色背景主题
o.termguicolors = true -- 启用 24 位真彩色支持

-- =====================
-- 显示设置
-- =====================
o.list = false -- 不显示不可见字符 (Tab、空格、换行符等)
o.wildmenu = true -- 命令行补全时显示候选菜单
o.pumheight = 10 -- 弹出菜单最大显示 10 行
o.showtabline = 1 -- 仅在有多个标签页时显示标签栏
o.showmode = false -- 不显示模式提示 (由状态栏插件处理)

-- =====================
-- 折叠设置
-- =====================
o.foldcolumn = "1" -- 显示折叠指示列 (宽度为 1)
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
o.foldlevelstart = 99 -- 打开文件时的折叠级别 (99 = 几乎全部展开)
o.foldenable = true -- 启用代码折叠功能
o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]

-- =====================
-- 禁用特定功能
-- =====================
g.zig_fmt_autosave = false -- 禁用 Zig 文件自动格式化
g.loaded_perl_provider = false -- 禁用 Perl 提供者 (加速启动)
g.loaded_netrw = 1 -- 禁用内置文件浏览器 netrw
g.loaded_netrwPlugin = 1 -- 禁用 netrw 插件
g.editorconfig = true -- 启用 EditorConfig 集成 (遵循项目 .editorconfig 配置)
