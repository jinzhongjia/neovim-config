if vim.g.vscode then
    return
end
-- replace default diagnostic signs
-- more:https://neovim.io/doc/user/diagnostic.html#diagnostic-signs
-- local signs = { Error = "󰅚", Warn = "", Hint = "", Info = "" }
-- for type, icon in pairs(signs) do
--     local hl = "DiagnosticSign" .. type
--     vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
-- end
vim.diagnostic.config({
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "󰅚",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.HINT] = "",
            [vim.diagnostic.severity.INFO] = "",
        },
        linehl = {
            -- [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
            -- [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
            -- [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
            -- [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
        },
        numhl = {
            [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
            [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
            [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
            [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
        },
    },
})
