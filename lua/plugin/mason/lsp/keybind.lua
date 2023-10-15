-- Multiplexing opt parameters
local opt = { noremap = true, silent = true }
local mapbuf = vim.api.nvim_buf_set_keymap
local M = {}
M.mapLSP = function(buffer_id)
    -- rename
    -- mapbuf("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opt)
    mapbuf(buffer_id, "n", "<leader>rn", "<cmd>LspUI rename<CR>", opt)

    -- code action
    -- mapbuf("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opt)
    mapbuf(buffer_id, "n", "<leader>ca", "<cmd>LspUI code_action<CR>", opt)

    -- go xx
    -- mapbuf("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opt)
    -- mapbuf("n", "gd", "<cmd>Glance definitions<CR>", opt)
    mapbuf(buffer_id, "n", "gd", "<cmd>LspUI definition<CR>", opt)

    -- hover document
    -- mapbuf("n", "gh", "<cmd>lua vim.lsp.buf.hover()<CR>", opt)
    mapbuf(buffer_id, "n", "K", "<cmd>LspUI hover<CR>", opt)

    -- declaration
    -- mapbuf("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opt)
    mapbuf(buffer_id, "n", "gD", "<cmd>LspUI declaration<CR>", opt)

    -- implementation
    -- mapbuf("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opt)
    -- mapbuf("n", "gi", "<cmd>Glance implementations<CR>", opt)
    mapbuf(buffer_id, "n", "gi", "<cmd>LspUI implementation<CR>", opt)

    -- references
    -- mapbuf("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opt)
    -- mapbuf("n", "gr", "<cmd>Glance references<CR>", opt)
    mapbuf(buffer_id, "n", "gr", "<cmd>LspUI reference<CR>", opt)

    -- diagnostic
    -- mapbuf("n", "gp", "<cmd>lua vim.diagnostic.open_float()<CR>", opt)
    -- mapbuf("n", "gk", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opt)
    mapbuf(buffer_id, "n", "gk", "<cmd>LspUI diagnostic prev<CR>", opt)
    -- mapbuf("n", "gj", "<cmd>lua vim.diagnostic.goto_next()<CR>", opt)
    mapbuf(buffer_id, "n", "gj", "<cmd>LspUI diagnostic next<CR>", opt)

    -- format
    -- mapbuf("n", "<leader>f", "<cmd>GuardFmt<CR>", opt)
    if vim.api.nvim_get_option_value("filetype", {
        buf = buffer_id,
    }) == "zig" then
        mapbuf(buffer_id, "n", "<leader>f", "<cmd>Zig fmt<CR>", opt)
    else
        mapbuf(buffer_id, "n", "<leader>f", "", {
            noremap = true,
            silent = true,
            callback = function()
                local conform = require("conform")
                conform.format({
                    bufnr = buffer_id,
                    async = false,
                    lsp_fallback = true,
                })
            end,
        })
    end

    -- mapbuf("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opt)

    -- type definition
    -- mapbuf("n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opt)
    -- mapbuf("n", "gtd", "<cmd>Glance type_definitions<CR>", opt)
    mapbuf(buffer_id, "n", "gy", "<cmd>LspUI type_definition<CR>", opt)
end

return M
