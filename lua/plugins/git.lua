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
            disable_signs = false, -- 保留符号
            
            -- 文件监视器优化
            filewatcher = {
                interval = 1000,
                enabled = true,
            },
            
            -- 控制台性能优化
            console_timeout = 2000, -- 2秒后显示慢命令的输出
            auto_show_console = true, -- 自动显示控制台
            auto_close_console = true, -- 成功时自动关闭控制台
            
            -- 图形样式
            graph_style = "unicode",
            
            -- 提交编辑器配置
            commit_editor = {
                kind = "tab",
                show_staged_diff = true, -- 显示暂存区差异
                staged_diff_split_kind = "split", -- 底部显示差异（横向分割）
                spell_check = true, -- 启用拼写检查
            },
            
            -- 视图配置优化
            kind = "tab", -- 默认在新标签页打开
            commit_view = {
                kind = "split", -- 横向分割显示提交详情
                verify_commit = vim.fn.executable("gpg") == 1, -- GPG 签名验证
            },
            
            -- 其他视图优化
            log_view = {
                kind = "tab",
            },
            rebase_editor = {
                kind = "auto", -- 自动选择最佳布局
            },
            reflog_view = {
                kind = "tab",
            },
            popup = {
                kind = "split", -- popup 使用横向分割
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
                recent_commit_count = 10, -- 只显示最近10个提交（性能优化）
                HEAD_padding = 10,
                HEAD_folded = false, -- 默认展开 HEAD
            },
            
            -- 分支排序
            sort_branches = "-committerdate", -- 按提交日期降序排序
            
            -- 日志视图配置
            commit_order = "topo", -- 拓扑排序（适合查看分支图）
            
            -- 性能优化：禁用行号
            disable_line_numbers = true,
            disable_relative_line_numbers = true,
            
            -- sections 配置（性能优化：默认折叠某些不常用的部分）
            sections = {
                stashes = {
                    folded = true, -- 默认折叠 stash
                    hidden = false,
                },
                unpulled_upstream = {
                    folded = true, -- 默认折叠未拉取的上游提交
                    hidden = false,
                },
                recent = {
                    folded = true, -- 默认折叠最近提交
                    hidden = false,
                },
                rebase = {
                    folded = false, -- rebase 状态不折叠
                    hidden = false,
                },
            },
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
    {
        "pwntester/octo.nvim",
        cmd = "Octo",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "folke/snacks.nvim",
            "nvim-tree/nvim-web-devicons",
        },
        opts = {
            -- 使用 Snacks picker
            picker = "snacks",
            
            -- 默认合并策略
            default_merge_method = "squash", -- 默认是 commit，这里自定义为 squash
        },
        keys = {
            -- Issue 操作
            { "<leader>oi", "<cmd>Octo issue list<cr>", desc = "List issues" },
            { "<leader>oI", "<cmd>Octo issue search<cr>", desc = "Search issues" },
            { "<leader>oc", "<cmd>Octo issue create<cr>", desc = "Create issue" },
            
            -- PR 操作
            { "<leader>op", "<cmd>Octo pr list<cr>", desc = "List PRs" },
            { "<leader>oP", "<cmd>Octo pr search<cr>", desc = "Search PRs" },
            { "<leader>opr", "<cmd>Octo pr create<cr>", desc = "Create PR" },
            { "<leader>opo", "<cmd>Octo pr<cr>", desc = "Open current branch PR" },
            
            -- Repo 操作
            { "<leader>or", "<cmd>Octo repo list<cr>", desc = "List repos" },
            { "<leader>oR", "<cmd>Octo repo browser<cr>", desc = "Open repo in browser" },
            
            -- 搜索
            { "<leader>os", "<cmd>Octo search<cr>", desc = "Search GitHub" },
            
            -- 其他
            { "<leader>oa", "<cmd>Octo actions<cr>", desc = "List Octo actions" },
        },
    },
    {
        "topaxi/pipeline.nvim",
        keys = {
            { "<leader>ci", "<cmd>Pipeline<cr>", desc = "Open pipeline" },
        },
        opts = {
            -- 刷新间隔（秒）
            refresh_interval = 10,
            
            -- 用于 dispatch workflow 的分支
            dispatch_branch = "default", -- "default", "current" 或具体分支名
            
            -- 分屏配置
            split = {
                relative = "editor",
                position = "right", -- "left", "right", "top", "bottom"
                size = 60,
            },
        },
    },
}
