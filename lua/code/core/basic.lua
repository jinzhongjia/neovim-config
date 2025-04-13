local vscode = require("vscode")
local o, g = vim.o, vim.g
vim.notify = vscode.notify

g.mapleader = " "

o.cursorline = true

o.ignorecase = true
o.smartcase = true
o.number = true
o.relativenumber = true
o.hlsearch = true
o.incsearch = true

o.backup = false
o.writebackup = false
o.swapfile = false

g.zig_fmt_autosave = false
g.loaded_perl_provider = false
g.editorconfig = false

o.updatetime = 300
o.timeoutlen = 400

o.mouse = "a"
