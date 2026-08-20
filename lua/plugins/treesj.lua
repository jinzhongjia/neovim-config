-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- treesj — 结构化 split / join（把参数列表、表、对象在一行与多行之间切）
-- 懒加载：setup 推迟到首次 <leader>m；关掉自带键位，只留一个 toggle
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local loaded = false

vim.keymap.set("n", "<leader>m", function()
    if not loaded then
        loaded = true
        require("treesj").setup({
            use_default_keymaps = false,
            max_join_length = 120, -- 跟 colorcolumn 对齐
        })
    end
    require("treesj").toggle()
end, { desc = "Split/join toggle (treesj)" })
