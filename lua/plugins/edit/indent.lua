return
--- @type LazySpec
{
    {
        "nmac427/guess-indent.nvim",
        event = "VeryLazy",
        opts = {},
    },
    {
        "saghen/blink.indent",
        event = "VeryLazy",
        --- @module 'blink.indent'
        --- @type blink.indent.Config
        opts = {
            blocked = {
                -- 默认禁用的 buftype 和 filetype
                buftypes = { include_defaults = true }, -- terminal, quickfix, nofile, prompt
                filetypes = { include_defaults = true, "dashboard", "mason", "codecompanion" }, -- 包含默认 + 额外的
            },
            static = {
                enabled = true,
                char = "▎",
                priority = 1,
                highlights = { "BlinkIndent" }, -- 使用单一颜色
            },
            scope = {
                enabled = true,
                char = "▎",
                priority = 1000,
                highlights = { "BlinkIndentScope" }, -- 使用单一颜色高亮当前作用域
            },
        },
    },
}
