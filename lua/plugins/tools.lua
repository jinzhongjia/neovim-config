-- some useful tools
return
--- @type LazySpec
{
    {
        "voldikss/vim-floaterm",
        -- 按键触发即可
        init = function()
            vim.g.floaterm_width = 0.85
            vim.g.floaterm_height = 0.8
        end,
        keys = {
            { "ft", "<CMD>FloatermNew<CR>", mode = { "n", "t" }, desc = "floaterm new" },
            { "fj", "<CMD>FloatermPrev<CR>", mode = { "n", "t" }, desc = "floaterm prev" },
            { "fk", "<CMD>FloatermNext<CR>", mode = { "n", "t" }, desc = "floaterm next" },
            { "fs", "<CMD>FloatermToggle<CR>", mode = { "n", "t" }, desc = "floaterm toggel" },
            { "fc", "<CMD>FloatermKill<CR>", mode = { "n", "t" }, desc = "floaterm kill" },
        },
    },
    {
        "askfiy/smart-translate.nvim",
        cmd = { "Translate" },
        dependencies = { "askfiy/http.nvim" },
        opts = {
            default = {
                cmds = {
                    source = "auto",
                    target = "zh-CN",
                    handle = "float",
                    engine = "google",
                },
                cache = true,
            },
        },
        keys = {
            { "<leader>ts", ":Translate<cr>", mode = { "n", "v" }, desc = "Translate selection" },
        },
    },
    {
        "folke/todo-comments.nvim",
        event = { "BufReadPost", "BufNewFile" }, -- 打开文件时高亮 TODO
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {},
    },
    {
        "jiaoshijie/undotree",
        ---@module 'undotree.collector'
        ---@type UndoTreeCollector.Opts
        opts = {
            -- your options
        },
        keys = { -- load the plugin only when using it's keybinding:
            { "<leader>u", "<cmd>lua require('undotree').toggle()<cr>" },
        },
    },
    {
        "stevearc/stickybuf.nvim",
        event = { "BufReadPost", "BufNewFile" }, -- 需要监控 buffer
        opts = {},
    },
    {
        "max397574/better-escape.nvim",
        event = "InsertEnter", -- 进入插入模式时加载
        opts = {
            default_mappings = false,
            mappings = {
                i = { j = { k = "<Esc>" } },
                c = { j = { k = "<Esc>" } },
                t = { j = { k = "<C-\\><C-n>" } },
                v = { j = { k = "<Esc>" } },
                s = { j = { k = "<Esc>" } },
            },
        },
    },
    {
        "chrishrb/gx.nvim",
        -- 按键触发即可
        keys = {
            { "gx", "<cmd>Browse<cr>", mode = { "n", "x" }, desc = "Browse URL" },
        },
        init = function()
            vim.g.netrw_nogx = 1 -- disable netrw gx
        end,
        dependencies = { "nvim-lua/plenary.nvim" }, -- Required for Neovim < 0.10.0
        config = true, -- default settings
        submodules = false, -- not needed, submodules are required only for tests
    },
    {
        "stevearc/quicker.nvim",
        event = "FileType qf",
        ---@module "quicker"
        ---@type quicker.SetupOptions
        opts = {},
    },
    {
        "stevearc/overseer.nvim",
        cmd = { "OverseerRun", "OverseerToggle", "OverseerOpen" }, -- 命令触发
        opts = {},
    },
    {
        "NStefan002/screenkey.nvim",
        cmd = "Screenkey", -- 命令触发
        version = "*", -- or branch = "dev", to use the latest commit
    },
    {
        "OXY2DEV/helpview.nvim",
        ft = "help", -- 打开 help 文件时加载
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
    },
    {
        "tweekmonster/helpful.vim",
        cmd = { "HelpfulVersion" }, -- 命令触发
    },
    {
        "2kabhishek/termim.nvim",
        -- 命令触发即可
        cmd = { "Fterm", "FTerm", "Sterm", "STerm", "Vterm", "VTerm" },
    },
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
            indent = { enabled = false }, -- 使用 blink.indent 替代
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
            statuscolumn = { enabled = true },
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
            -- Lazygit
            {
                "<leader>gg",
                function()
                    Snacks.lazygit()
                end,
                desc = "Lazygit",
            },
            {
                "<leader>gB",
                function()
                    Snacks.gitbrowse()
                end,
                desc = "Git Browse",
                mode = { "n", "v" },
            },

            -- Notifications
            {
                "<leader>sn",
                function()
                    Snacks.notifier.show_history()
                end,
                desc = "Notification History",
            },
            {
                "<leader>un",
                function()
                    Snacks.notifier.hide()
                end,
                desc = "Dismiss All Notifications",
            },

            -- Buffer Management
            {
                "<leader>bd",
                function()
                    Snacks.bufdelete()
                end,
                desc = "Delete Buffer",
            },
            {
                "<leader>bo",
                function()
                    Snacks.bufdelete.other()
                end,
                desc = "Delete Other Buffers",
            },
            {
                "<leader>bO",
                function()
                    Snacks.bufdelete.all()
                end,
                desc = "Delete All Buffers",
            },

            -- Scratch Buffers
            {
                "<leader>.",
                function()
                    Snacks.scratch()
                end,
                desc = "Toggle Scratch Buffer",
            },
            {
                "<leader>S",
                function()
                    Snacks.scratch.select()
                end,
                desc = "Select Scratch Buffer",
            },

            -- Debug
            {
                "<leader>dps",
                function()
                    Snacks.profiler.scratch()
                end,
                desc = "Profiler Scratch Buffer",
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
            {
                "<leader>fc",
                function()
                    Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
                end,
                desc = "Config files",
            },
            {
                "<leader>fp",
                function()
                    Snacks.picker.projects()
                end,
                desc = "Projects",
            },

            -- ===== Picker: Git (leader-g = git) =====
            {
                "<leader>gb",
                function()
                    Snacks.picker.git_branches()
                end,
                desc = "Branches",
            },
            {
                "<leader>gc",
                function()
                    Snacks.picker.git_log()
                end,
                desc = "Commits",
            },
            {
                "<leader>gC",
                function()
                    Snacks.picker.git_log_file()
                end,
                desc = "Buffer commits",
            },
            {
                "<leader>gs",
                function()
                    Snacks.picker.git_status()
                end,
                desc = "Status",
            },
            {
                "<leader>gS",
                function()
                    Snacks.picker.git_stash()
                end,
                desc = "Stash",
            },
            {
                "<leader>gd",
                function()
                    Snacks.picker.git_diff()
                end,
                desc = "Git Diff (Hunks)",
            },
            {
                "<leader>gf",
                function()
                    Snacks.picker.git_log_file()
                end,
                desc = "Git File History",
            },
            {
                "<leader>gl",
                function()
                    Snacks.picker.git_log()
                end,
                desc = "Git Log",
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
            {
                "<leader>sb",
                function()
                    Snacks.picker.lines()
                end,
                desc = "Buffer lines",
            },
            {
                "<leader>sB",
                function()
                    Snacks.picker.grep_buffers()
                end,
                desc = "Grep open buffers",
            },
            {
                "<leader>sg",
                function()
                    Snacks.picker.grep()
                end,
                desc = "Grep",
            },
            {
                "<leader>sw",
                function()
                    Snacks.picker.grep_word()
                end,
                desc = "Grep word",
                mode = { "n", "x" },
            },
            {
                "<leader>sR",
                function()
                    Snacks.picker.resume()
                end,
                desc = "Resume",
            },

            -- ===== Picker: 打开 (leader-o = open) =====
            {
                "<leader>ob",
                function()
                    Snacks.picker.buffers()
                end,
                desc = "Buffers",
            },
            {
                "<leader>oB",
                function()
                    Snacks.picker.recent()
                end,
                desc = "Recent files",
            },
            {
                "<leader>ol",
                function()
                    Snacks.picker.lines()
                end,
                desc = "Lines (buffer)",
            },
            {
                "<leader>ok",
                function()
                    Snacks.picker.keymaps()
                end,
                desc = "Keymaps",
            },
            {
                "<leader>oC",
                function()
                    Snacks.picker.colorschemes()
                end,
                desc = "Colorschemes",
            },
            {
                "<leader>om",
                function()
                    Snacks.picker.marks()
                end,
                desc = "Marks",
            },
            {
                "<leader>oM",
                function()
                    Snacks.picker.man()
                end,
                desc = "Man pages",
            },
            {
                "<leader>or",
                function()
                    Snacks.picker.registers()
                end,
                desc = "Registers",
            },
            {
                "<leader>oA",
                function()
                    Snacks.picker.autocmds()
                end,
                desc = "Autocmds",
            },
            {
                "<leader>oj",
                function()
                    Snacks.picker.jumps()
                end,
                desc = "Jumps",
            },
            {
                "<leader>oH",
                function()
                    Snacks.picker.command_history()
                end,
                desc = "Command history",
            },
            {
                "<leader>o/",
                function()
                    Snacks.picker.search_history()
                end,
                desc = "Search history",
            },
            {
                "<leader>oq",
                function()
                    Snacks.picker.qflist()
                end,
                desc = "Quickfix",
            },
            {
                "<leader>oL",
                function()
                    Snacks.picker.loclist()
                end,
                desc = "Location list",
            },
            {
                "<leader>ou",
                function()
                    Snacks.picker.undo()
                end,
                desc = "Undo history",
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
            {
                "<leader>tr",
                function()
                    Snacks.picker.resume()
                end,
                desc = "Resume search",
            },
        },

        init = function()
            vim.api.nvim_create_autocmd("User", {
                pattern = "VeryLazy",
                callback = function()
                    -- Setup debug helpers (lazy-loaded)
                    _G.dd = function(...)
                        Snacks.debug.inspect(...)
                    end
                    _G.bt = function()
                        Snacks.debug.backtrace()
                    end

                    -- Override print to use snacks for `:=` command
                    if vim.fn.has("nvim-0.11") == 1 then
                        vim._print = function(_, ...)
                            dd(...)
                        end
                    else
                        vim.print = _G.dd
                    end

                    Snacks.toggle
                        .option("conceallevel", {
                            off = 0,
                            on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2,
                        })
                        :map("<leader>uc")
                    Snacks.toggle.treesitter():map("<leader>uT")
                    Snacks.toggle
                        .option("background", {
                            off = "light",
                            on = "dark",
                            name = "Dark Background",
                        })
                        :map("<leader>ub")
                    Snacks.toggle.dim():map("<leader>uD")
                    -- scroll 已禁用,移除相关 toggle
                end,
            })
        end,
    },
    {
        "ovk/endec.nvim",
        cmd = { "Endec", "EndecEncode", "EndecDecode" }, -- 命令触发
        opts = {
            -- Override default configuration here
        },
    },
    {
        "ellisonleao/dotenv.nvim",
        cmd = "Dotenv", -- 命令触发
        opts = {
            {
                enable_on_load = false,
            },
        },
    },
    {
        "tpope/vim-repeat",
        event = { "BufReadPost", "BufNewFile" }, -- 编辑时需要
    },
    {
        "MonsieurTib/package-ui.nvim",
        -- 命令触发
        cmd = "PackageUi",
        config = function()
            require("package-ui").setup()
        end,
    },
    {
        "bassamsdata/namu.nvim",
        opts = {
            global = {},
            namu_symbols = { -- Specific Module options
                options = {},
            },
        },
        keys = {
            { "<leader>ss", ":Namu symbols<cr>", mode = { "n" }, desc = "Jump to LSP symbol" },
            { "<leader>sw", ":Namu workspace<cr>", mode = { "n" }, desc = "LSP Symbols - Workspace" },
        },
    },
    {
        "hat0uma/prelive.nvim",
        -- 命令触发即可
        cmd = {
            "PreLiveGo",
            "PreLiveStatus",
            "PreLiveClose",
            "PreLiveCloseAll",
            "PreLiveLog",
        },
        opts = {
            server = {
                -- 强烈建议不要暴露到外部网络
                host = "127.0.0.1",
                -- 如果值为 0，服务器将绑定到随机端口
                port = 2255,
            },
            log = {
                print_level = vim.log.levels.WARN,
                file_level = vim.log.levels.DEBUG,
                max_file_size = 1 * 1024 * 1024,
                max_backups = 3,
            },
        },
        keys = {
            { "<leader>ps", "<cmd>PreLiveGo<cr>", mode = { "n" }, desc = "PreLive: Start server" },
            { "<leader>pt", "<cmd>PreLiveStatus<cr>", mode = { "n" }, desc = "PreLive: Status" },
            { "<leader>pc", "<cmd>PreLiveClose<cr>", mode = { "n" }, desc = "PreLive: Close" },
            { "<leader>pa", "<cmd>PreLiveCloseAll<cr>", mode = { "n" }, desc = "PreLive: Close all" },
            { "<leader>pl", "<cmd>PreLiveLog<cr>", mode = { "n" }, desc = "PreLive: View logs" },
        },
    },
}
