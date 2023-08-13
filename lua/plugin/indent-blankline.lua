local status, ident_blankline = pcall(require, "indent_blankline")
if not status then
    vim.notify("not found indent_blankline")
    return
end

ident_blankline.setup {
    space_char_blankline = " ",
    show_current_context = true,
    show_current_context_start = true,
}
