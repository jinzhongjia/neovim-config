-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- render-markdown — Markdown 缓冲区内渲染
-- 由 lazy.nvim 按文件类型加载。
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

require("render-markdown").setup({
    file_types = { "markdown", "opencode_output", "omp_output" },

    anti_conceal = {
        enabled = true,
        disabled_modes = { "n" },
        above = 0,
        below = 0,
    },
    win_options = {
        concealcursor = { rendered = "n" },
    },

    completions = {
        blink = { enabled = true },
    },

    checkbox = {
        unchecked = { icon = "✘ " },
        checked = { icon = "✔ " },
        custom = { todo = { rendered = "◯ " } },
    },

    overrides = {
        buftype = {
            nofile = {
                render_modes = true,
                sign = { enabled = false },
                padding = { highlight = "NormalFloat" },
            },
        },
        filetype = {
            opencode_output = {
                anti_conceal = { enabled = false },
            },
            omp_output = {
                anti_conceal = { enabled = false },
            },
        },
    },
})
