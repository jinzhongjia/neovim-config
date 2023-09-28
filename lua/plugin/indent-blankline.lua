local status, ibl = pcall(require, "ibl")
if not status then
    vim.notify("not found indent_blankline")
    return
end

local highlight = {
    "CursorColumn",
    "Whitespace",
}

ibl.setup {
    indent = { highlight = highlight, char = "" },
    whitespace = {
        highlight = highlight,
        remove_blankline_trail = false,
    },
    scope = { enabled = false },
}
