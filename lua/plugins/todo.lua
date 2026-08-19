-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- todo-comments — TODO/FIXME/HACK/NOTE 高亮 + 搜索
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local todo = require("todo-comments")

todo.setup({})

-- todo-comments 在 setup 时看到 Snacks 就会注册 todo_comments picker source
vim.keymap.set("n", "<leader>st", function()
    Snacks.picker.todo_comments()
end, { desc = "Search TODOs" })
vim.keymap.set("n", "]t", todo.jump_next, { desc = "Next TODO" })
vim.keymap.set("n", "[t", todo.jump_prev, { desc = "Prev TODO" })
