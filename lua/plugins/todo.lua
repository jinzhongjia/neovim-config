-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- TODO/FIXME/HACK/NOTE 高亮 + 跳转 + 搜索（替掉 todo-comments.nvim）
-- 高亮用窗口级 matchadd，搜索走 snacks grep，只认 `KEYWORD:` 形式。
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local groups = {
    DiagnosticError = { "FIX", "FIXME", "BUG" },
    DiagnosticWarn = { "HACK", "WARN", "WARNING", "XXX" },
    DiagnosticInfo = { "TODO" },
    DiagnosticHint = { "NOTE", "INFO", "PERF", "TEST" },
}

local all = {}
for _, words in pairs(groups) do
    vim.list_extend(all, words)
end

-- matchadd 是窗口局部的，每个窗口补一次
local function highlight()
    if vim.w.todo_matches then
        return
    end
    vim.w.todo_matches = true
    for hl, words in pairs(groups) do
        vim.fn.matchadd(hl, [[\C\<\(]] .. table.concat(words, [[\|]]) .. [[\):]])
    end
end

vim.api.nvim_create_autocmd({ "VimEnter", "WinNew" }, {
    group = vim.api.nvim_create_augroup("TodoHighlight", { clear = true }),
    callback = highlight,
})

local vim_pat = [[\C\<\(]] .. table.concat(all, [[\|]]) .. [[\):]]
local rg_pat = [[\b(]] .. table.concat(all, "|") .. [[):]]

vim.keymap.set("n", "<leader>st", function()
    Snacks.picker.grep({ search = rg_pat, live = false })
end, { desc = "Search TODOs" })
vim.keymap.set("n", "]t", function()
    vim.fn.search(vim_pat, "w")
end, { desc = "Next TODO" })
vim.keymap.set("n", "[t", function()
    vim.fn.search(vim_pat, "bw")
end, { desc = "Prev TODO" })
