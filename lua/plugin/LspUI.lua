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

tool.map("n", "<leader>rn", "<cmd>LspUI rename<CR>")
tool.map("n", "<leader>ca", "<cmd>LspUI code_action<CR>")
tool.map("n", "gd", "<cmd>LspUI definition<CR>")
tool.map("n", "K", "<cmd>LspUI hover<CR>")
tool.map("n", "gD", "<cmd>LspUI declaration<CR>")
tool.map("n", "gi", "<cmd>LspUI implementation<CR>")
tool.map("n", "gr", "<cmd>LspUI reference<CR>")
tool.map("n", "gk", "<cmd>LspUI diagnostic prev<CR>")
tool.map("n", "gj", "<cmd>LspUI diagnostic next<CR>")
tool.map("n", "gy", "<cmd>LspUI type_definition<CR>")
