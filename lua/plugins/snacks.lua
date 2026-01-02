return
--- @type LazySpec
{
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        ---@type snacks.Config
        opts = {
            -- 启用的功能模块
            bigfile = { enabled = true },
            bufdelete = { enabled = true },
            dashboard = { enabled = false }, -- 如果使用其他 dashboard 插件，设为 false
            dim = { enabled = true },
            explorer = { enabled = false }, -- 如果使用 nvim-tree，设为 false
            git = { enabled = true },
            gitbrowse = { enabled = true },
            indent = { enabled = true }, -- 使用 blink.indent 替代
            input = { enabled = true },
            notifier = {
                enabled = true,
                timeout = 3000,
                width = { min = 40, max = 0.4 },
                height = { min = 1, max = 0.6 },
                margin = { top = 0, right = 1, bottom = 0 },
                padding = true,
                sort = { "level", "added" },
                level = vim.log.levels.TRACE,
                icons = {
                    error = " ",
                    warn = " ",
                    info = " ",
                    debug = " ",
                    trace = " ",
                },
                style = "compact",
            },
            picker = {
                enabled = true,
                -- 全局排除 Go 生成文件的配置
                sources = {
                    files = {
                        exclude = { "*.gen.go", "gen.go", "*.pb.go", "*.connector.go", "*.connect.go" },
                    },
                    git_files = {
                        exclude = { "*.gen.go", "gen.go", "*.pb.go", "*.connector.go", "*.connect.go" },
                    },
                    smart = {
                        -- smart 会继承 files 的配置,所以无需额外配置 exclude
                    },
                    recent = {
                        -- recent files 使用 filter.paths 来排除,pattern 需要匹配完整路径
                        -- 使用自定义 filter 函数来支持 glob patterns
                        filter = {
                            filter = function(item, filter)
                                local path = item.file or item.text or ""
                                -- 排除以这些后缀结尾的文件
                                return not (
                                    path:match("%.gen%.go$")
                                    or path:match("/gen%.go$")
                                    or path:match("%.pb%.go$")
                                    or path:match("%.connector%.go$")
                                    or path:match("%.connect%.go$")
                                )
                            end,
                        },
                    },
                    grep = {
                        exclude = { "*.gen.go", "gen.go", "*.pb.go", "*.connector.go", "*.connect.go" },
                    },
                    grep_word = {
                        exclude = { "*.gen.go", "gen.go", "*.pb.go", "*.connector.go", "*.connect.go" },
                    },
                    grep_buffers = {
                        exclude = { "*.gen.go", "gen.go", "*.pb.go", "*.connector.go", "*.connect.go" },
                    },
                },
            },
            quickfile = { enabled = true },
            rename = { enabled = false }, -- 使用 LspUI rename 替代
            scope = { enabled = true }, -- 代码作用域检测
            scratch = { enabled = true },
            scroll = { enabled = false }, -- 平滑滚动动画影响性能,禁用
            statuscolumn = {
                enabled = true,
                left = { "mark", "sign" }, -- 左侧: 标记、诊断图标
                right = { "fold", "git" }, -- 右侧: 折叠图标、git 状态
                folds = {
                    open = true, -- 显示展开的折叠图标
                    git_hl = true, -- 折叠图标使用 Git Signs 高亮
                },
            },
            terminal = { enabled = true },
            toggle = { enabled = true },
            words = { enabled = true }, -- 高亮相同单词并导航
            zen = { enabled = false }, -- 使用 zen-mode.nvim + twilight.nvim 替代

            -- 样式配置
            styles = {
                notification = {
                    wo = { wrap = true },
                },
                terminal = {
                    position = "float",
                    border = "rounded",
                    width = 0.8,
                    height = 0.8,
                },
                scratch = {
                    border = "rounded",
                    width = 0.8,
                    height = 0.8,
                },
                zen = {
                    enter = true,
                    fixbuf = false,
                    minimal = false,
                    width = 120,
                    height = 0,
                    backdrop = { transparent = false, blend = 40 },
                    show = {
                        statusline = false,
                        tabline = false,
                    },
                    win = { style = "" },
                },
            },
        },

        keys = {
            -- Notifications
            {
                "<leader>sn",
                function()
                    Snacks.notifier.show_history()
                end,
                desc = "Notification History",
            },
            -- ===== Picker: 快速查找 (Ctrl+p/f) =====
            {
                "<leader>ff",
                function()
                    Snacks.picker.files()
                end,
                desc = "Files",
            },
            {
                "<leader>fF",
                function()
                    Snacks.picker.files({ hidden = true, ignored = true })
                end,
                desc = "Files (all)",
            },
            {
                "<leader>fg",
                function()
                    Snacks.picker.grep()
                end,
                desc = "Grep",
            },
            {
                "<leader>fG",
                function()
                    Snacks.picker.grep({ hidden = true, ignored = true })
                end,
                desc = "Grep (all)",
            },

            -- ===== Picker: 查找和搜索 (leader-f = find) =====
            {
                "<leader>fb",
                function()
                    Snacks.picker.buffers()
                end,
                desc = "Buffers",
            },
            {
                "<leader>fr",
                function()
                    Snacks.picker.recent()
                end,
                desc = "Recent files",
            },

            -- ===== Picker: LSP 符号 (leader-s = search/symbols) =====
            {
                "<leader>ss",
                function()
                    Snacks.picker.lsp_symbols()
                end,
                desc = "Document symbols",
            },
            {
                "<leader>sS",
                function()
                    Snacks.picker.lsp_workspace_symbols()
                end,
                desc = "Workspace symbols",
            },
            {
                "<leader>sd",
                function()
                    Snacks.picker.diagnostics_buffer()
                end,
                desc = "Document diagnostics",
            },
            {
                "<leader>sD",
                function()
                    Snacks.picker.diagnostics()
                end,
                desc = "Workspace diagnostics",
            },

            -- ===== Picker: 搜索内容 (leader-/ = search) =====
            {
                "<leader>/",
                function()
                    Snacks.picker.grep()
                end,
                desc = "Live grep",
            },
            {
                "<leader>*",
                function()
                    Snacks.picker.grep_word()
                end,
                desc = "Grep cursor word",
            },

            -- ===== Picker: Tabs =====
            {
                "<leader>tt",
                function()
                    Snacks.picker.pickers()
                end,
                desc = "All pickers",
            },
        },
    },
}

