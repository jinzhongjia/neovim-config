-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- numb — :行号跳转前预览
-- 由 lazy.nvim 在首次 CmdlineEnter 时加载。
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

require("numb").setup({
    show_numbers = true,
    show_cursorline = true,
    hide_relativenumbers = true,
    centered_peeking = true,
})
