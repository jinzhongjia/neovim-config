local status, bufferline = pcall(require, "bufferline")
if not status then
  vim.notify("not found bufferline")
  return
end

-- bufferline config
-- https://github.com/akinsho/bufferline.nvim#configuration
bufferline.setup({
  options = {
    -- To close the Tab command, use moll/vim-bbye's :Bdelete command here
    close_command = "Bdelete! %d",
    right_mouse_command = "Bdelete! %d",
    -- Using nvim's built-in LSP will be configured later in the course
    diagnostics = "coc",
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

local tool = require("tool")
tool.map("n", "<Tab>", ":BufferLineCycleNext<cr>")
tool.map("n", "bn", ":BufferLineCycleNext<cr>")
tool.map("n", "<S-Tab>", ":BufferLineCyclePrev<cr>")
tool.map("n", "bp", ":BufferLineCyclePrev<cr>")
tool.map("n", "bd", ":Bdelete<cr>")

tool.map("n", "<leader>bl", ":BufferLineCloseRight<cr>")
tool.map("n", "<leader>bh", ":BufferLineCloseLeft<cr>")
tool.map("n", "<leader>bn", ":BufferLineMoveNext<cr>")
tool.map("n", "<leader>bp", ":BufferLineMovePrev<cr>")