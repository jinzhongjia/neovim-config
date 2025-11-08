return
--- @type LazySpec
{
    {
        "echasnovski/mini.diff",
        version = "*",
        event = { "BufReadPost", "BufNewFile" }, -- 需要实时显示 diff
        opts = {},
    },
    {
        "rbong/vim-flog",
        cmd = { "Flog", "Flogsplit", "Floggit" }, -- 命令触发
        dependencies = {
            "tpope/vim-fugitive",
        },
    },
    {
        "NeogitOrg/neogit",
        dependencies = {
            "nvim-lua/plenary.nvim", -- required
            "sindrets/diffview.nvim", -- optional - Diff integration

            -- Only one of these is needed.
            "folke/snacks.nvim",
        },
        cmd = "Neogit", -- 命令触发
        opts = {
            -- 性能优化
            auto_refresh = true, -- 自动刷新状态
            disable_hint = false, -- 保留顶部提示
            disable_context_highlighting = false, -- 保留上下文高亮
            
            -- 文件监视器优化
            filewatcher = {
                interval = 1000,
                enabled = true,
            },
            
            -- 图形样式
            graph_style = "unicode",
            
            -- 提交编辑器配置
            commit_editor = {
                kind = "tab",
                show_staged_diff = true, -- 显示暂存区差异
                staged_diff_split_kind = "vsplit", -- 右侧显示差异
                spell_check = true, -- 启用拼写检查
            },
            
            -- 视图配置优化
            kind = "tab", -- 默认在新标签页打开
            commit_view = {
                kind = "vsplit",
                verify_commit = vim.fn.executable("gpg") == 1, -- GPG 签名验证
            },
            
            -- 集成配置
            integrations = {
                snacks = true,
                diffview = true, -- 启用 diffview 集成
            },
            
            -- 记住设置（跨会话保持开关/选项状态）
            remember_settings = true,
            use_per_project_settings = true,
            
            -- 映射配置
            mappings = {
                finder = {
                    ["<C-j>"] = "Next",
                    ["<C-k>"] = "Previous",
                },
                status = {
                    ["<C-r>"] = "RefreshBuffer", -- 添加手动刷新快捷键
                },
            },
            
            -- 状态视图配置
            status = {
                show_head_commit_hash = true,
                recent_commit_count = 10,
                HEAD_padding = 10,
            },
            
            -- 分支排序
            sort_branches = "-committerdate", -- 按提交日期降序排序
            
            -- 日志视图配置
            commit_order = "topo", -- 拓扑排序（适合查看分支图）
        },
        keys = {
            { "<leader>ng", "<cmd>Neogit<cr>", desc = "NeoGit" },
        },
    },
    {
        "sindrets/diffview.nvim",
        cmd = { "DiffviewOpen", "DiffviewFileHistory" }, -- 命令触发
    },
    {
        "FabijanZulj/blame.nvim",
        cmd = { "BlameToggle", "BlameEnable" }, -- 命令触发
        opts = {},
        keys = {
            { "<leader>bt", "<cmd>BlameToggle<cr>", desc = "Blame toggle" },
        },
    },
    {
        "akinsho/git-conflict.nvim",
        event = { "BufReadPost", "BufNewFile" }, -- 需要检测冲突标记
        version = "*",
        config = true,
    },
    {
        "isakbm/gitgraph.nvim",
        dependencies = { "sindrets/diffview.nvim" },
        ---@type I.GGConfig
        opts = {
            symbols = {
                merge_commit = "M",
                commit = "*",
            },
            format = {
                timestamp = "%H:%M:%S %d-%m-%Y",
                fields = { "hash", "timestamp", "author", "branch_name", "tag" },
            },
            hooks = {
                -- Check diff of a commit
                on_select_commit = function(commit)
                    vim.notify("DiffviewOpen " .. commit.hash .. "^!")
                    vim.cmd(":DiffviewOpen " .. commit.hash .. "^!")
                end,
                -- Check diff from commit a -> commit b
                on_select_range_commit = function(from, to)
                    vim.notify("DiffviewOpen " .. from.hash .. "~1.." .. to.hash)
                    vim.cmd(":DiffviewOpen " .. from.hash .. "~1.." .. to.hash)
                end,
            },
        },
        keys = {
            {
                "<leader>gl",
                function()
                    require("gitgraph").draw({}, { all = true, max_count = 5000 })
                end,
                desc = "GitGraph - Draw",
            },
        },
    },
}
