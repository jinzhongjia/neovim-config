local o, g = vim.o, vim.g
o.encoding = "utf-8"
o.fileencoding = "utf-8"

o.scrolloff = 5
o.sidescroll = 5

o.autochdir = false

o.number = true
o.relativenumber = true

-- highlight current row
o.cursorline = true

o.signcolumn = "yes"

o.colorcolumn = "80"

o.tabstop = 4
o.softtabstop = 4
o.shiftround = true

o.shiftwidth = 4

o.expandtab = true

o.autoindent = true
o.smartindent = true

o.ignorecase = true
o.smartcase = true

o.hlsearch = true
o.incsearch = true

o.cmdheight = 1

o.autoread = true

o.wrap = false
o.whichwrap = "b,s,<,>,[,]"

o.hidden = true

o.mouse = "a"

o.backup = false
o.writebackup = false
o.swapfile = false

o.updatetime = 300
o.timeoutlen = 400

o.splitbelow = true
o.splitright = true

o.completeopt = "menu,menuone,noselect,noinsert"

o.background = "dark"

o.termguicolors = true

o.list = true
-- o.listchars = "space:·,tab:··,eol:↴"
o.listchars = "eol:↴"

o.wildmenu = true

o.pumheight = 10

o.showtabline = 1

o.showmode = false

o.foldcolumn = "1"
o.foldlevel = 99
o.foldlevelstart = 99
o.foldenable = true
o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]

g.zig_fmt_autosave = false
g.loaded_perl_provider = false

-- diasble netrw
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1

-- disable editorconfig integration
g.editorconfig = false
