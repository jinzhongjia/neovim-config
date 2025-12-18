return
--- @type LazySpec
{
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPost", "BufNewFile" }, -- 需要实时显示 diff
        opts = {
            signs = {
                add = { text = "┃" },
                change = { text = "┃" },
                delete = { text = "_" },
                topdelete = { text = "‾" },
                changedelete = { text = "~" },
                untracked = { text = "┆" },
            },
            signs_staged = {
                add = { text = "┃" },
                change = { text = "┃" },
                delete = { text = "_" },
                topdelete = { text = "‾" },
                changedelete = { text = "~" },
            },
            signs_staged_enable = true,
            signcolumn = true, -- 显示 sign column
            numhl = true, -- 高亮行号 - 更直观地看到修改
            linehl = false, -- 不高亮整行（太干扰）
            word_diff = false, -- 不默认显示 word diff（按需使用）
            watch_gitdir = {
                follow_files = true, -- 跟随文件移动
            },
            auto_attach = true,
            attach_to_untracked = true, -- 附加到未跟踪的文件
            current_line_blame = false, -- 默认不显示当前行 blame（按需开启，避免干扰）
            current_line_blame_opts = {
                virt_text = true,
                virt_text_pos = "eol", -- 显示在行尾
                delay = 1000, -- 延迟 1000ms 显示，避免频繁切换行时闪烁
                ignore_whitespace = false,
                virt_text_priority = 100,
                use_focus = true, -- 只在窗口聚焦时显示
            },
            current_line_blame_formatter = "  <author> • <author_time:%Y-%m-%d> • <summary>",
            sign_priority = 6,
            update_debounce = 100,
            status_formatter = nil, -- 使用默认格式化
            max_file_length = 40000, -- 文件超过 40000 行则禁用
            preview_config = {
                border = "rounded",
                style = "minimal",
                relative = "cursor",
                row = 0,
                col = 1,
            },
            diff_opts = {
                algorithm = "histogram", -- 更好的 diff 算法
                internal = true, -- 使用内置 diff 库
                indent_heuristic = true, -- 启用缩进启发式
                vertical = true, -- 垂直分屏显示 diff
                linematch = 60, -- 启用行匹配（对齐相似行），提升 diff 质量
            },
            on_attach = function(bufnr)
                local gitsigns = require("gitsigns")

                local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                end

                -- Navigation - 增强版：自动打开折叠和可选预览
                map("n", "<leader>nh", function()
                    gitsigns.nav_hunk("next", {
                        wrap = true, -- 循环跳转
                        navigation_message = true, -- 显示导航消息
                        foldopen = true, -- 自动打开折叠
                        preview = false, -- 不自动预览（可以手动 hp）
                    })
                end, { desc = "Next hunk" })

                map("n", "<leader>ph", function()
                    gitsigns.nav_hunk("prev", {
                        wrap = true,
                        navigation_message = true,
                        foldopen = true,
                        preview = false,
                    })
                end, { desc = "Previous hunk" })

                map("n", "<leader>hB", gitsigns.blame, { desc = "Blame buffer" })

                -- Quickfix / Location list
                map("n", "<leader>hq", function()
                    gitsigns.setqflist("all")
                end, { desc = "Hunks to quickfix (all)" })
                map("n", "<leader>hl", function()
                    gitsigns.setloclist(0)
                end, { desc = "Hunks to loclist" })
            end,
        },
    },
    {
        "rbong/vim-flog",
        cmd = { "Flog", "Flogsplit", "Floggit" }, -- 命令触发
        dependencies = {
            "tpope/vim-fugitive",
        },
    },
    {
        "tpope/vim-fugitive",
        event = { "VeryLazy" }, -- 需要 git 功能时加载
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
            picker_config = {
                search_static = false,
            },
        },
        keys = {
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
            dispatch_branch = "current", -- "default", "current" 或具体分支名

            -- 分屏配置
            split = {
                relative = "editor",
                position = "bottom", -- "left", "right", "top", "bottom"
                size = 60,
            },
        },
    },
    {
        -- NOTE: we need addational config for this plugin
        "esmuellert/vscode-diff.nvim",
        dependencies = { "MunifTanjim/nui.nvim" },
        enabled = false,
        cmd = "CodeDiff", -- 命令触发，避免影响启动性能
        config = function()
            require("vscode-diff").setup({
                -- 高亮配置 - 自动适应你的配色方案
                highlights = {
                    -- 行级：使用配色方案的 DiffAdd 和 DiffDelete
                    line_insert = "DiffAdd",
                    line_delete = "DiffDelete",

                    -- 字符级：nil = 自动根据背景调整亮度
                    -- 深色主题会自动 1.4x 增亮，浅色主题会 0.92x 变暗
                    char_insert = nil,
                    char_delete = nil,

                    -- 也可以手动指定亮度倍数（覆盖自动检测）
                    -- char_brightness = 1.4,
                },

                -- Diff 视图行为
                diff = {
                    disable_inlay_hints = true, -- 在 diff 窗口中禁用 inlay hints
                    max_computation_time_ms = 5000, -- diff 计算最大时间
                },
            })
        end,
        keys = {
            -- Git diff 模式 - 与指定版本比较当前文件
            { "<leader>gdh", "<cmd>CodeDiff file HEAD<cr>", desc = "Diff with HEAD" },
            { "<leader>gdH", "<cmd>CodeDiff file HEAD~1<cr>", desc = "Diff with HEAD~1" },

            -- 文件浏览器模式 - 显示所有变更的文件
            { "<leader>gdf", "<cmd>CodeDiff<cr>", desc = "Diff file explorer" },

            -- 与指定版本比较（需要输入版本号）
            { "<leader>gdc", ":CodeDiff file ", desc = "Diff with commit...", silent = false },

            -- 文件比较模式（需要输入两个文件路径）
            { "<leader>gd2", ":CodeDiff file ", desc = "Diff two files...", silent = false },
        },
    },
}
