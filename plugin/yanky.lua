-- 创建一个突显复制行的函数
local function highlight_yank()
    vim.highlight.on_yank({
        higroup = "IncSearch", -- 使用 IncSearch 高亮组
        timeout = 200, -- 高亮持续 200 毫秒
        on_visual = true, -- 在可视模式中也启用
    })
end

-- 创建自动命令来调用这个函数
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = highlight_yank,
    desc = "高亮显示被复制的文本",
})
