return {
    "sindrets/diffview.nvim",
    config = function()
        require("diffview").setup({
            enhanced_diff_hl = true, -- 启用增强高亮，模拟 VSCode 风格
            view = {
                default = { layout = "diff2_horizontal" }, -- 水平并排视图
            },
        })
    end,
}
