local status, lualine = pcall(require, "lualine")
if not status then
    vim.notify("not found lualine")
    return
end
lualine.setup()
