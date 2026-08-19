-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- which-key — 按下前缀键后弹出可用键位速查
-- 映射本体都在各自模块里定义，这里只补分组标签
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

require("which-key").setup({
    win = { border = "rounded" },
    spec = {
        { "<leader>a", group = "AI (Claude)", mode = { "n", "v" } },
        { "<leader>b", group = "Buffers" },
        { "<leader>c", group = "Code (LSP)" },
        { "<leader>d", group = "Debug / Diagnostics", mode = { "n", "v" } },
        { "<leader>f", group = "Find (snacks picker)" },
        { "<leader>g", group = "Git" },
        { "<leader>i", group = "Inlay hints" },
        { "<leader>l", group = "LSP pickers" },
        { "<leader>o", group = "OpenCode" },
        { "<leader>s", group = "Search / Split", mode = { "n", "v" } },
        { "<leader>t", group = "Terminal" },
        { "<leader>T", group = "Toggle (snacks)" },
        { "<leader>w", group = "Window (press w alone to save)" },
        { "<leader>z", group = "Zen / Zoom" },
        { "gs", group = "Surround" },
    },
})
