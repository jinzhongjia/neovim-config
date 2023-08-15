local status, gitsigns = pcall(require, "gitsigns")
if not status then
    vim.notify("not found gitsignss")
    return
end

gitsigns.setup()
