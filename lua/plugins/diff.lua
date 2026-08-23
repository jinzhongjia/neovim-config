-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- mini.diff — gutter 变更标记 + hunk 级操作
-- 默认键位：gh 暂存 hunk（operator）、gH 撤销 hunk、[h/]h 跳转、
-- ih textobject；状态栏 +~- 计数读 vim.b.minidiff_summary
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local diff = require("mini.diff")

diff.setup({
    view = {
        style = "sign",
        signs = { add = "▎", change = "▎", delete = "" },
    },
})

vim.keymap.set("n", "<leader>Go", diff.toggle_overlay, { desc = "Diff overlay (mini.diff)" })
