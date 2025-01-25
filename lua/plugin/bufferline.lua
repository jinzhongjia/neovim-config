local status, bufferline = pcall(require, "bufferline")
if not status then
    vim.notify("not found bufferline")
    return
end

-- bufferline config
-- https://github.com/akinsho/bufferline.nvim#configuration
---@diagnostic disable-next-line: missing-fields
bufferline.setup({
    ---@diagnostic disable-next-line: missing-fields
    options = {
        -- To close the Tab command, use moll/vim-bbye's :Bdelete command here
        close_command = "Bdelete! %d",
        right_mouse_command = "Bdelete! %d",
        -- Using nvim's built-in LSP will be configured later in the course
        diagnostics = "nvim_lsp",
        -- Optional, show LSP error icon
        ---@diagnostic disable-next-line: unused-local
        diagnostics_indicator = function(count, level, diagnostics_dict, context)
            local s = " "
            for e, n in pairs(diagnostics_dict) do
                local sym = e == "error" and "" or (e == "warning" and "" or "")
                s = s .. n .. sym
            end
            return s
        end,
    },
})

__key_bind("n", "bn", "<CMD>BufferLineCycleNext<cr>")
__key_bind("n", "bp", "<CMD>BufferLineCyclePrev<cr>")
__key_bind("n", "bd", "<CMD>Bdelete!<cr>")
__key_bind("n", "<leader>bl", "<CMD>BufferLineCloseRight<cr>")
__key_bind("n", "<leader>bh", "<CMD>BufferLineCloseLeft<cr>")
__key_bind("n", "<leader>bn", "<CMD>BufferLineMoveNext<cr>")
__key_bind("n", "<leader>bp", "<CMD>BufferLineMovePrev<cr>")
