--- @type ("pwsh"|"nu")?
local windows_shell = "pwsh"
local o = vim.o
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

vim.o.list = true
vim.o.listchars = "space:·,tab:··,eol:↴"

o.wildmenu = true

o.pumheight = 10

o.showtabline = 1

o.showmode = false

o.foldcolumn = "1"
o.foldlevel = 99
o.foldlevelstart = 99
o.foldenable = true
o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]

vim.g.zig_fmt_autosave = false

vim.g.loaded_perl_provider = false

-- diasble netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- replace default diagnostic signs
-- more:https://neovim.io/doc/user/diagnostic.html#diagnostic-signs
-- local signs = { Error = "󰅚", Warn = "", Hint = "", Info = "" }
-- for type, icon in pairs(signs) do
--     local hl = "DiagnosticSign" .. type
--     vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
-- end
vim.diagnostic.config({
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "󰅚",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.HINT] = "",
            [vim.diagnostic.severity.INFO] = "",
        },
        linehl = {
            -- [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
            -- [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
            -- [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
            -- [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
        },
        numhl = {
            [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
            [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
            [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
            [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
        },
    },
})

vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("highlight_on_yank", {}),
    desc = "Briefly highlight yanked text",
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- when on windows and pwsh exists
-- this is for pwsh
if vim.fn.has("win32") == 1 and vim.fn.executable("pwsh") == 1 and windows_shell == "pwsh" then
    -- https://github.com/neovim/neovim/issues/15634
    vim.o.shell = "pwsh"
    vim.o.shellcmdflag =
        "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
    vim.o.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
    vim.o.shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait"
    vim.o.shellxquote = ""
    vim.o.shellquote = ""
end

if vim.fn.executable("nu") == 1 and windows_shell == "nu" then
    vim.o.shell = "nu"
    vim.o.shellcmdflag = "-c"
    vim.o.shellquote = ""
    vim.o.shellxquote = ""
end

-- add Config command to chdir cwd to config path
vim.api.nvim_create_user_command("Config", function()
    --- @type string
    ---@diagnostic disable-next-line: assign-type-mismatch
    local config_path = vim.fn.stdpath("config")
    vim.fn.chdir(config_path)
end, {
    desc = "command for config",
})

-- reload buffer on focus
vim.api.nvim_create_autocmd({
    "FocusGained",
    "BufEnter",
    "CursorHold",
}, {
    desc = "Reload buffer on focus",
    callback = function()
        if vim.fn.getcmdwintype() == "" then
            vim.cmd("checktime")
        end
    end,
})
