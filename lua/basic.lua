local opt = vim.opt
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"

opt.scrolloff = 5
opt.sidescroll = 5

opt.autochdir = false

opt.number = true
opt.relativenumber = true

-- highlight current row
opt.cursorline = true

opt.signcolumn = "yes"

opt.colorcolumn = "80"

opt.tabstop = 4
opt.softtabstop = 4
opt.shiftround = true

opt.shiftwidth = 4

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
opt.timeoutlen = 400

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
opt.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]

vim.g.zig_fmt_autosave = false

-- diasble netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- replace default diagnostic signs
-- more:https://neovim.io/doc/user/diagnostic.html#diagnostic-signs
local signs = { Error = "󰅚", Warn = "", Hint = "", Info = "" }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

if not vim.g.neovide then
    -- Put anything you want to happen only in Neovide here
    return
end

-- Here is for neovide
do
    local xdg_session = os.getenv("XDG_SESSION_TYPE")

    if xdg_session == "x11" then
        vim.o.guifont = "Maple Mono NF:h11"
    else
        vim.o.guifont = "Maple Mono NF:h15"
    end
end

vim.g.neovide_padding_top = 0
vim.g.neovide_padding_bottom = 0
vim.g.neovide_padding_right = 0
vim.g.neovide_padding_left = 0

vim.g.neovide_floating_blur_amount_x = 2.0
vim.g.neovide_floating_blur_amount_y = 2.0

vim.g.neovide_transparency = 0.9

vim.g.neovide_hide_mouse_when_typing = true

vim.g.neovide_refresh_rate = 144

vim.g.neovide_refresh_rate_idle = 5

vim.g.neovide_fullscreen = true

vim.g.neovide_remember_window_size = true

vim.g.neovide_cursor_antialiasing = true

vim.g.neovide_input_ime = false

vim.g.neovide_cursor_animation_length = 0
