-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Performance-first options for Neovim 0.12
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Disable unused providers for faster startup
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python3_provider = 0

-- Disable unused built-in plugins
vim.g.loaded_gzip = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1
vim.g.loaded_tutor_mode_plugin = 1

-- Let conform/LSP own formatting, not the zig ftplugin
vim.g.zig_fmt_autosave = false

local o = vim.o

-- UI
o.number = true
o.relativenumber = true
o.signcolumn = "yes"
o.cursorline = true
o.termguicolors = true
o.showmode = false -- statusline handles this
o.laststatus = 3 -- global statusline
o.cmdheight = 1
o.pumheight = 12
o.pumborder = "rounded" -- 0.12: popup menu border
o.pummaxwidth = 50 -- 0.12: popup max width
o.winborder = "rounded" -- 0.12: floating window border
o.scrolloff = 8
o.sidescrolloff = 8
o.sidescroll = 5 -- horizontal scroll step (wrap is off)
o.wrap = false
o.colorcolumn = "120"
o.background = "dark"

-- Editing
o.expandtab = true
o.tabstop = 4
o.shiftwidth = 4
o.softtabstop = 4
o.smartindent = true
o.breakindent = true
o.shiftround = true -- round indent to a shiftwidth multiple
o.whichwrap = "b,s,<,>,[,]" -- let these keys cross line boundaries

-- Search
o.ignorecase = true
o.smartcase = true
o.hlsearch = true
o.incsearch = true

-- Performance
o.updatetime = 200
o.timeoutlen = 300
o.redrawtime = 1500
o.lazyredraw = false -- incompatible with noice-like UIs

-- Files
o.exrc = true -- 项目本地 .nvim.lua（内置信任机制，首次会询问）
o.undofile = true
o.swapfile = false
o.backup = false
o.writebackup = false

-- Completion — blink.cmp owns insert completion (plugins/completion.lua),
-- so native 'autocomplete' stays off; completeopt only serves manual <C-x>
o.completeopt = "menu,menuone,noselect,popup,nearest"
o.shortmess = vim.o.shortmess .. "c"

-- Command-line completion
o.wildmenu = true
o.wildmode = "longest:full,full" -- 第一次 Tab: 最长公共前缀，第二次: 循环
o.wildoptions = "pum,fuzzy" -- 弹出菜单 + 模糊匹配
o.wildchar = 9 -- Tab 触发（0.12 中也支持 / ? :g :v 搜索补全）

-- Split
o.splitbelow = true
o.splitright = true
o.splitkeep = "screen"

-- Grep (use ripgrep if available)
if vim.fn.executable("rg") == 1 then
    o.grepprg = "rg --vimgrep --smart-case --hidden"
    o.grepformat = "%f:%l:%c:%m"
end

-- Diff (0.12 improved defaults)
o.diffopt = "internal,filler,closeoff,indent-heuristic,inline:char,algorithm:histogram"

-- Mouse
o.mouse = "a"
o.mousemodel = "extend"

-- Clipboard
if vim.fn.has("win32") == 1 and vim.fn.executable("win32yank.exe") == 1 then
    vim.g.clipboard = "win32yank" -- 0.12: built-in provider by name
end
o.clipboard = "unnamedplus"

-- Fold (treesitter-based)
o.foldmethod = "expr"
o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
o.foldlevel = 99
o.foldlevelstart = 99
o.foldenable = true
-- 'statuscolumn' 由 snacks 接管（plugins/snacks.lua）：它自己画 mark/sign/
-- fold/git，折叠图标取的就是下面 'fillchars' 里的 foldopen/foldclose。
-- 'foldcolumn' 必须非 "0"：snacks 拿它当"要不要画折叠图标"的开关；整列
-- 渲染已经被 statuscolumn 接管，所以这个 1 不会真的多占一列宽度。
o.foldcolumn = "1"
o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
