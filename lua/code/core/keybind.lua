local vscode = require("vscode")
local opt = { noremap = true, silent = true, nowait = true }

local function key_bind(mode, lhs, cb)
    opt.callback = cb
    vim.api.nvim_set_keymap(mode, lhs, "", opt)
end

key_bind("n", "<leader>ca", function()
    vim.lsp.buf.code_action()
end)

key_bind("n", "gr", function()
    vim.lsp.buf.references()
end)

key_bind("n", "gi", function()
    vim.lsp.buf.implementation()
end)

key_bind("n", "<leader>f", function()
    vscode.action("editor.action.formatDocument")
end)

key_bind("n", "<leader>rn", function()
    vim.lsp.buf.rename()
end)

key_bind("n", "<leader>ca", function()
    vim.lsp.buf.code_action()
end)
