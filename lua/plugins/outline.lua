-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- outline.nvim — 符号大纲侧边栏（LSP document symbols 的常驻视图）
-- 与 <leader>ls（snacks picker 弹窗式）互补：这个用来长时间挂着导航
-- 懒加载：setup 推迟到首次 <leader>lo，命令在那之前不存在
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local loaded = false
local function outline(cmd)
    return function()
        if not loaded then
            loaded = true
            require("outline").setup({
                outline_window = {
                    position = "right",
                    width = 25,
                    relative_width = true,
                    auto_close = false,
                    focus_on_open = true,
                    show_numbers = false,
                    wrap = false,
                },
                outline_items = {
                    show_symbol_details = true,
                    show_symbol_lineno = false,
                    highlight_hovered_item = true,
                    auto_set_cursor = true,
                },
                -- 顶层符号默认展开，深层折叠；光标悬停自动展开
                symbol_folding = {
                    autofold_depth = 2,
                    auto_unfold = { hovered = true },
                },
                preview_window = {
                    auto_preview = false,
                    border = "rounded",
                },
                guides = { enabled = true },
                keymaps = {
                    close = { "<Esc>", "q" },
                    goto_location = "<CR>",
                    peek_location = "o",
                    goto_and_close = "<S-CR>",
                    hover_symbol = "K",
                    rename_symbol = "r",
                    code_actions = "a",
                    fold = "h",
                    unfold = "l",
                    fold_toggle = "<Tab>",
                    fold_all = "W",
                    unfold_all = "E",
                },
            })
        end
        vim.cmd(cmd)
    end
end

vim.keymap.set("n", "<leader>lo", outline("Outline"), { desc = "Outline (symbols) toggle" })
vim.keymap.set("n", "<leader>lO", outline("OutlineFocus"), { desc = "Outline focus" })
