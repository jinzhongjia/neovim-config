-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- render-markdown — Markdown 缓冲区内渲染
-- 从 main 分支移植，剥掉 codecompanion 专属部分（HTML tag 图标、
-- 聊天高亮组）；conceal 行为与 checkbox 样式保持原样
-- 加载花 ~9ms 且只服务 markdown，挂首个 markdown FileType；
-- setup 后同一 buffer 的 BufWinEnter 会完成 attach
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "markdown", "opencode_output" },
    group = vim.api.nvim_create_augroup("RenderMarkdownLazy", { clear = true }),
    once = true,
    callback = function()
        require("render-markdown").setup({
            file_types = { "markdown", "opencode_output" },

            -- Normal 模式保持预览效果，避免光标所在行露出原始 Markdown 符号
            anti_conceal = {
                enabled = true,
                disabled_modes = { "n" },
                above = 0,
                below = 0,
            },
            win_options = {
                concealcursor = { rendered = "n" },
            },

            -- checkbox / callout 补全走 blink 源（插件自注册）
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
                    -- nofile buffer（如 opencode 输出）：全模式渲染、去掉 sign 列
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
                },
            },
        })
    end,
})
