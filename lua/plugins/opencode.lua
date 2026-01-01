return
--- @type LazySpec
{
    {
        "sudo-tee/opencode.nvim",
        event = "VeryLazy",
        opts = {
            -- 文件类型配置
            filetype = "opencode_output",
            -- 窗口配置
            win = {
                border = "rounded",
                width = 0.8,
                height = 0.8,
            },
            -- 渲染配置
            render = {
                enabled = true,
            },
        },
    },
}

