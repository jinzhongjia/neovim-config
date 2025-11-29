return
--- @type LazySpec
{
    {
        "folke/persistence.nvim",
        event = "BufReadPre", -- 仅在打开实际文件时启动会话保存
        opts = {
            dir = vim.fn.stdpath("state") .. "/sessions/", -- 会话文件保存目录
            need = 1, -- 保存会话所需的最少文件缓冲区数（设置为 0 总是保存）
            branch = true, -- 使用 git 分支来保存会话
        },
        keys = {
            -- 加载当前目录的会话
            {
                "<leader>qs",
                function()
                    require("persistence").load()
                end,
                desc = "Restore Session",
            },

            -- 选择一个会话加载
            {
                "<leader>qS",
                function()
                    require("persistence").select()
                end,
                desc = "Select Session",
            },

            -- 加载上一个会话
            {
                "<leader>ql",
                function()
                    require("persistence").load({ last = true })
                end,
                desc = "Restore Last Session",
            },

            -- 停止持久化（这次退出时不保存会话）
            {
                "<leader>qd",
                function()
                    require("persistence").stop()
                end,
                desc = "Don't Save Session",
            },
        },
    },
}
