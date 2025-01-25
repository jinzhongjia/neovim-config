local status, LspUI = pcall(require, "LspUI")
if not status then
    vim.notify("not found LspUI")
    return
end

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
    inlay_hint = {
        enable = false,
    },
})

__key_bind("n", "<leader>rn", "<CMD>LspUI rename<CR>")
__key_bind("n", "<leader>ca", "<CMD>LspUI code_action<CR>")
__key_bind("n", "gd", "<CMD>LspUI definition<CR>")
__key_bind("n", "K", "<CMD>LspUI hover<CR>")
__key_bind("n", "gD", "<CMD>LspUI declaration<CR>")
__key_bind("n", "gi", "<CMD>LspUI implementation<CR>")
__key_bind("n", "gr", "<CMD>LspUI reference<CR>")
__key_bind("n", "gk", "<CMD>LspUI diagnostic prev<CR>")
__key_bind("n", "gj", "<CMD>LspUI diagnostic next<CR>")
__key_bind("n", "gy", "<CMD>LspUI type_definition<CR>")
