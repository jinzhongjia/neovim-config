local status, zig = pcall(require, "Zig")
if not status then
    vim.notify("not found zig")
    return
end

-- Multiplexing opt parameters
local opt = { noremap = true, silent = true }
local mapbuf = vim.api.nvim_buf_set_keymap

local mapLSP = function(buffer_id)
    mapbuf(buffer_id, "n", "<leader>rn", "<cmd>LspUI rename<CR>", opt)
    mapbuf(buffer_id, "n", "<leader>ca", "<cmd>LspUI code_action<CR>", opt)
    mapbuf(buffer_id, "n", "gd", "<cmd>LspUI definition<CR>", opt)
    mapbuf(buffer_id, "n", "gh", "<cmd>LspUI hover<CR>", opt)
    mapbuf(buffer_id, "n", "gD", "<cmd>LspUI declaration<CR>", opt)
    mapbuf(buffer_id, "n", "gi", "<cmd>LspUI implementation<CR>", opt)
    mapbuf(buffer_id, "n", "gr", "<cmd>LspUI reference<CR>", opt)
    mapbuf(buffer_id, "n", "gk", "<cmd>LspUI diagnostic prev<CR>", opt)
    mapbuf(buffer_id, "n", "gj", "<cmd>LspUI diagnostic next<CR>", opt)
    mapbuf(buffer_id, "n", "<leader>f", "<cmd>Zig fmt<CR>", opt)
    mapbuf(buffer_id, "n", "gy", "<cmd>LspUI type_definition<CR>", opt)
end

zig.setup({
    zls = {
        lspconfig_opt = {
            on_attach = function(client, bufnr)
                mapLSP(bufnr)
            end,
        },
    },
})
