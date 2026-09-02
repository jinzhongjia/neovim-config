-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Neogit — magit 式 git 界面
-- 由 lazy.nvim 在 :Neogit 或首次按键时加载。
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

require("neogit").setup({
    graph_style = "unicode",
    commit_editor = { staged_diff_split_kind = "vsplit" },
})

vim.keymap.set("n", "<leader>ng", "<cmd>Neogit<CR>", { desc = "NeoGit" })
