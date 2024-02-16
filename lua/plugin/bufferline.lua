local status, bufferline = pcall(require, "bufferline")
if not status then
    vim.notify("not found bufferline")
    return
end

local tool = require("tool")

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

-- tool.map("n", "<Tab>", ":BufferLineCycleNext<cr>")
tool.map("n", "bn", "<CMD>BufferLineCycleNext<cr>")
-- tool.map("n", "<S-Tab>", ":BufferLineCyclePrev<cr>")
tool.map("n", "bp", "<CMD>BufferLineCyclePrev<cr>")
tool.map("n", "bd", "<CMD>Bdelete!<cr>")

tool.map("n", "<leader>bl", "<CMD>BufferLineCloseRight<cr>")
tool.map("n", "<leader>bh", "<CMD>BufferLineCloseLeft<cr>")
tool.map("n", "<leader>bn", "<CMD>BufferLineMoveNext<cr>")
tool.map("n", "<leader>bp", "<CMD>BufferLineMovePrev<cr>")
