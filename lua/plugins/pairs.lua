-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Auto pairs — blink.pairs (Rust matcher, syntax-aware)
-- 加载要花 ~16ms（download 版本检查 + Rust 库），挂到首次
-- InsertEnter：配对只在编辑时才需要，启动路径上省掉这笔
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

vim.api.nvim_create_autocmd("InsertEnter", {
    group = vim.api.nvim_create_augroup("BlinkPairsLazy", { clear = true }),
    once = true,
    callback = function()
        -- download() 是官方 vim.pack 写法：拉取与 tag 匹配的预编译
        -- 二进制，已是当前版本时为 no-op
        require("blink.pairs").download():pwait(60000)
        require("blink.pairs").setup()
    end,
})
