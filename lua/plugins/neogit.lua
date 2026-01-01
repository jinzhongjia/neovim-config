return 
--- @type LazySpec
{
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

            -- 控制台性能优化
            console_timeout = 2000, -- 2秒后显示慢命令的输出
            auto_show_console = true, -- 自动显示控制台
            auto_close_console = true, -- 成功时自动关闭控制台

            -- 图形样式
            graph_style = "unicode",
            -- process_spinner = true,

            -- Git 性能优化
            use_default_keymaps = true,
            disable_insert_on_commit = true, -- 提交时不自动进入插入模式

            -- 大仓库优化
            fetch_after_checkout = false, -- 切换分支后不自动 fetch

            -- 提交编辑器配置
            commit_editor = {
                kind = "tab",
                show_staged_diff = true, -- 显示暂存区差异
                staged_diff_split_kind = "vsplit", -- 右侧显示差异（左右布局）
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
                telescope = false, -- 禁用 telescope 集成以提升性能
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
}