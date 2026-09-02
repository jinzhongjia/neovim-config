-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- nvim-tree — file explorer (replaces netrw)
-- 由 lazy.nvim 在命令、按键或目录启动时加载。
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

require("nvim-tree").setup({
    view = { adaptive_size = true },
    disable_netrw = true,
    hijack_netrw = true,
    sync_root_with_cwd = true,
    update_focused_file = { enable = true },
    filters = {
        dotfiles = true,
        custom = { "node_modules", "^.git$" },
    },
    actions = {
        open_file = {
            resize_window = true,
            quit_on_open = true,
        },
    },
    live_filter = {
        prefix = "[FILTER]: ",
        always_show_folders = false,
    },
    git = { timeout = 1000 },
    diagnostics = {
        enable = true,
        show_on_dirs = true,
    },
    select_prompts = true,
})
