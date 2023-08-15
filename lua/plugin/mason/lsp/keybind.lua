-- Multiplexing opt parameters
local opt = { noremap = true, silent = true }
local M = {}
M.mapLSP = function(mapbuf)
    -- rename
    -- mapbuf("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opt)
    mapbuf("n", "<leader>rn", "<cmd>LspUI rename<CR>", opt)

    -- code action
    -- mapbuf("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opt)
    mapbuf("n", "<leader>ca", "<cmd>LspUI code_action<CR>", opt)

    -- go xx
    -- mapbuf("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opt)
    mapbuf("n", "gd", "<cmd>Glance definitions<CR>", opt)

    -- hover document
    -- mapbuf("n", "gh", "<cmd>lua vim.lsp.buf.hover()<CR>", opt)
    mapbuf("n", "gh", "<cmd>LspUI hover<CR>", opt)

    -- declaration
    mapbuf("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opt)

    -- implementation
    -- mapbuf("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opt)
    mapbuf("n", "gi", "<cmd>Glance implementations<CR>", opt)

    -- references
    -- mapbuf("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opt)
    mapbuf("n", "gr", "<cmd>Glance references<CR>", opt)

    -- diagnostic
    -- mapbuf("n", "gp", "<cmd>lua vim.diagnostic.open_float()<CR>", opt)
    -- mapbuf("n", "gk", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opt)
    mapbuf("n", "gk", "<cmd>LspUI diagnostic prev<CR>", opt)
    -- mapbuf("n", "gj", "<cmd>lua vim.diagnostic.goto_next()<CR>", opt)
    mapbuf("n", "gj", "<cmd>LspUI diagnostic next<CR>", opt)

    -- format
    mapbuf("n", "<leader>f", "<cmd>GuardFmt<CR>", opt)

    -- mapbuf("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opt)

    -- type definition
    -- mapbuf("n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opt)
    mapbuf("n", "<space>D", "<cmd>Glance type_definitions<CR>", opt)
end

return M
