-- Multiplexing opt parameters
local M = {}
M.mapLSP = function(buffer_id)
    vim.api.nvim_buf_set_keymap(buffer_id, "n", "<leader>f", "", {
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

return M
