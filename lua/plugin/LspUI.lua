local status, LspUI = pcall(require, "LspUI")
if not status then
    vim.notify("not found LspUI")
    return
end

local tool = require("tool")

local transparency = vim.g.neovide and 45 or 0

LspUI.setup({
    hover = {
        transparency = transparency,
    },
    rename = {
        transparency = transparency,
    },
    code_action = {
        transparency = transparency,
    },
    diagnostic = {
        transparency = transparency,
    },
    pos_keybind = {
        transparency = transparency,
    },
    signature = {
        enable = true,
    },
})

tool.map("n", "<leader>rn", "<CMD>LspUI rename<CR>")
tool.map("n", "<leader>ca", "<CMD>LspUI code_action<CR>")
tool.map("n", "gd", "<CMD>LspUI definition<CR>")
tool.map("n", "K", "<CMD>LspUI hover<CR>")
tool.map("n", "gD", "<CMD>LspUI declaration<CR>")
tool.map("n", "gi", "<CMD>LspUI implementation<CR>")
tool.map("n", "gr", "<CMD>LspUI reference<CR>")
tool.map("n", "gk", "<CMD>LspUI diagnostic prev<CR>")
tool.map("n", "gj", "<CMD>LspUI diagnostic next<CR>")
tool.map("n", "gy", "<CMD>LspUI type_definition<CR>")
