-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- outline.nvim — 符号大纲侧边栏
-- 由 lazy.nvim 在命令或按键首次触发时加载。
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

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
