local status, tint = pcall(require, "tint")
if not status then
    vim.notify("not found tint.nvim")
    return
end

---@diagnostic disable-next-line: missing-parameter
tint.setup()
