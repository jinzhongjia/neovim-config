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
        "voldikss/vim-translator",
        -- 按键触发(通常有快捷键)
        cmd = { "Translate", "TranslateW", "TranslateR", "TranslateX" },
    },
    {
        "chrisgrieser/nvim-early-retirement",
        event = { "BufReadPost", "BufNewFile" }, -- 需要监控 buffer 活动
        config = true,
    },
    {
        "folke/todo-comments.nvim",
        event = { "BufReadPost", "BufNewFile" }, -- 打开文件时高亮 TODO
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {},
    },
    {
        "simnalamburt/vim-mundo",
        -- 按键触发即可
        keys = {
            -- stylua: ignore
            { "<leader>ud", "<CMD>MundoToggle<CR>", mode = { "n" }, desc = "Toggle Mundo" },
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
            scope = { enabled = true }, -- 代码作用域检测,与 scope.nvim (tab-buffer 隔离) 功能不重叠
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
            -- Terminal
            { "<c-/>", function() Snacks.terminal() end, desc = "Toggle Terminal" },
            { "<c-_>", function() Snacks.terminal() end, desc = "which_key_ignore" },
            
            -- Lazygit
            { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
            { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse", mode = { "n", "v" } },
            { "<leader>gf", function() Snacks.lazygit.log_file() end, desc = "Lazygit File History" },
            { "<leader>gl", function() Snacks.lazygit.log() end, desc = "Lazygit Log (cwd)" },
            
            -- Notifications
            { "<leader>n", function() Snacks.notifier.show_history() end, desc = "Notification History" },
            { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
            
            -- Buffer Management
            { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
            { "<leader>bo", function() Snacks.bufdelete.other() end, desc = "Delete Other Buffers" },
            { "<leader>bO", function() Snacks.bufdelete.all() end, desc = "Delete All Buffers" },
            
            -- Scratch Buffers
            { "<leader>.", function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
            { "<leader>S", function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
            
            -- Word Navigation (LSP references)
            { "]]", function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference", mode = { "n", "t" } },
            { "[[", function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference", mode = { "n", "t" } },
            
            -- Debug
            { "<leader>dps", function() Snacks.profiler.scratch() end, desc = "Profiler Scratch Buffer" },
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

                    -- Create toggle mappings
                    Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
                    Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
                    Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
                    Snacks.toggle.diagnostics():map("<leader>ud")
                    Snacks.toggle.line_number():map("<leader>ul")
                    Snacks.toggle.option("conceallevel", { 
                        off = 0, 
                        on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 
                    }):map("<leader>uc")
                    Snacks.toggle.treesitter():map("<leader>uT")
                    Snacks.toggle.option("background", { 
                        off = "light", 
                        on = "dark", 
                        name = "Dark Background" 
                    }):map("<leader>ub")
                    Snacks.toggle.inlay_hints():map("<leader>uh")
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
