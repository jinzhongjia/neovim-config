local status, aerial = pcall(require, "aerial")
if not status then
    vim.notify("not found aerial")
    return
end

local tool = require("tool")

aerial.setup({
    layout = {
        min_width = 20,
    },
})

tool.map("n", "<leader>a", "<cmd>AerialToggle!<CR>")
