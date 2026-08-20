-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- numb — 敲 :123 时先跳过去预览，回车才真跳，Esc 回原位
-- 懒加载：只在第一次进 cmdline 时 setup
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

vim.api.nvim_create_autocmd("CmdlineEnter", {
    group = vim.api.nvim_create_augroup("NumbLazy", { clear = true }),
    once = true,
    callback = function()
        require("numb").setup({
            show_numbers = true,
            show_cursorline = true,
            hide_relativenumbers = true,
            centered_peeking = true,
        })
    end,
})
