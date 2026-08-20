-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- better-escape — 插入模式连打 jk / jj 回 normal，且不留下延迟感
-- 懒加载：首次 InsertEnter
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

vim.api.nvim_create_autocmd("InsertEnter", {
    group = vim.api.nvim_create_augroup("BetterEscapeLazy", { clear = true }),
    once = true,
    callback = function()
        require("better_escape").setup({})
    end,
})
