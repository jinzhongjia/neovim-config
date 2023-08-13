local opt = vim.opt
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"

opt.scrolloff = 5
opt.sidescroll = 5

opt.number = true
opt.relativenumber = true


-- highlight current row
opt.cursorline = true

opt.signcolumn = "yes"

opt.colorcolumn = "80"

opt.tabstop = 2
opt.softtabstop = 2
opt.shiftround = true

opt.shiftwidth = 2

opt.expandtab = true

opt.autoindent = true
opt.smartindent = true

opt.ignorecase = true
opt.smartcase = true

opt.hlsearch = true
opt.incsearch = true

opt.cmdheight = 1

opt.autoread = true

opt.wrap = false
opt.whichwrap = "b,s,<,>,[,]"

opt.hidden = true

opt.mouse = "a"

opt.backup = false
opt.writebackup = false
opt.swapfile = false

opt.updatetime = 300
opt.timeoutlen = 500

opt.splitbelow = true
opt.splitright = true

opt.completeopt = "menu,menuone,noselect,noinsert"

opt.background = "dark"

opt.termguicolors = true

vim.o.list = true
vim.o.listchars = "space:·,tab:··,eol:↴"

opt.wildmenu = true

opt.pumheight = 10

opt.showtabline = 1

opt.showmode = false

opt.foldcolumn = "1"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true

vim.g.zig_fmt_autosave = false

-- diasble netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
