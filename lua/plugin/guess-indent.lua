local status, guess_indent = pcall(require, "guess-indent")
if not status then
    vim.notify("not found guess-indent")
    return
end

guess_indent.setup()
