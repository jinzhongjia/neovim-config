-- setting for windows pwsh
if vim.fn.has("win32") == 1 then
    -- https://github.com/neovim/neovim/issues/15634
    vim.o.shell = "pwsh"
    vim.o.shellcmdflag =
        "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
    vim.o.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
    vim.o.shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait"
    vim.o.shellxquote = ""
    vim.o.shellquote = ""
end
