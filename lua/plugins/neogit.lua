-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Neogit — magit 式 git 界面（stage/commit/rebase/log 全键盘操作）
-- 只写与 upstream 默认值不同的项：kind=tab、stashes/recent/unpulled 默认折叠、
-- disable_line_numbers、integrations 自动探测（会认出已装的 snacks）都已是默认。
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- ponytail: setup() 约 13ms，推到第一个事件循环 tick，不算进启动时间。
-- :Neogit 命令由插件自带 plugin/neogit.lua 注册，不依赖 setup 先跑。
vim.schedule(function()
    require("neogit").setup({
        graph_style = "unicode", -- 默认 ascii
        commit_editor = { staged_diff_split_kind = "vsplit" }, -- 写 commit 时右侧看 staged diff
    })
end)

vim.keymap.set("n", "<leader>ng", "<cmd>Neogit<CR>", { desc = "NeoGit" })
