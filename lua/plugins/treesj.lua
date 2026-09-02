-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- treesj — 结构化 split / join
-- 由 lazy.nvim 在首次 <leader>m 时加载。
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local treesj = require("treesj")

treesj.setup({
    use_default_keymaps = false,
    max_join_length = 120,
})

vim.keymap.set("n", "<leader>m", treesj.toggle, { desc = "Split/join toggle (treesj)" })
