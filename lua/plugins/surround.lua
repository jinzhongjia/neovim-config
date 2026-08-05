-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- mini.surround — 包围操作
-- s/S 被 flash 占用（不动），改用 gs 前缀（gs 原是无用的 :sleep）
-- gsaiw" 给词加引号 · gsd" 删引号 · gsr"' 双引号换单引号
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

require("mini.surround").setup({
    mappings = {
        add = "gsa",
        delete = "gsd",
        find = "gsf",
        find_left = "gsF",
        highlight = "gsh",
        replace = "gsr",
        update_n_lines = "gsn",
    },
})
