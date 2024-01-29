local status, diffview = pcall(require, "diffview")
if not status then
    vim.notify("not found diffview")
    return
end

diffview.setup()
