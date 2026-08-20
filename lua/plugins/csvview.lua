-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- csvview — CSV/TSV 按列对齐显示
-- 懒加载：首个 csv/tsv buffer 才 setup；显示与否自己按 :CsvViewToggle，
-- 大文件默认不主动接管（跟 main 分支行为一致）
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("CsvViewLazy", { clear = true }),
    pattern = { "csv", "tsv" },
    once = true,
    callback = function()
        require("csvview").setup({})
    end,
})
