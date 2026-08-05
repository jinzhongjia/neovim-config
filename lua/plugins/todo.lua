-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- todo-comments — TODO/FIXME/HACK/NOTE 高亮 + 搜索
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local todo = require("todo-comments")

todo.setup({})

vim.keymap.set("n", "<leader>st", "<cmd>TodoFzfLua<CR>", { desc = "Search TODOs" })
vim.keymap.set("n", "]t", todo.jump_next, { desc = "Next TODO" })
vim.keymap.set("n", "[t", todo.jump_prev, { desc = "Prev TODO" })
