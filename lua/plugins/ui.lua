-- setting for bufferline, lualine, auto sized window
vim.g.gitblame_display_virtual_text = 0

local is_insert = false
local is_blame = false

return
--- @type LazySpec
{
    {
        "akinsho/bufferline.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        event = "UIEnter",
        opts = {
            options = {
                mode = "buffers", -- 显示 buffers 而不是 tabs
                always_show_bufferline = true, -- 始终显示 bufferline
                indicator = {
                    style = "icon",
                    icon = " ",
                },
                -- separator_style = "slant", -- 分隔符样式
                -- show_buffer_close_icons = true,
                -- show_close_icon = true,
                -- color_icons = true,
                offsets = {
                    { filetype = "NvimTree", text = "EXPLORER", text_align = "center" },
                    { filetype = "Outline", text = "OUTLINE", text_align = "center" },
                    { filetype = "codecompanion", text = "CodeCompanion", text_align = "center" },
                },
                show_tab_indicators = true,
                -- Use snacks.nvim's bufdelete for smart buffer deletion
                close_command = function(bufnr)
                    require("snacks").bufdelete(bufnr)
                end,
                right_mouse_command = function(bufnr)
                    require("snacks").bufdelete(bufnr)
                end,
                -- Using nvim's built-in LSP will be configured later in the course
                diagnostics = "nvim_lsp",
                -- Optional, show LSP error icon
                ---@diagnostic disable-next-line: unused-local
                diagnostics_indicator = function(count, level, diagnostics_dict, context)
                    local s = " "
                    for e, n in pairs(diagnostics_dict) do
                        local sym = e == "error" and "" or (e == "warning" and "" or "")
                        s = s .. n .. sym
                    end
                    return s
                end,
                -- 自定义过滤器，可以过滤某些 buffer 类型
                custom_filter = function(buf_number, buf_numbers)
                    -- 过滤 quickfix 等特殊 buffer
                    if vim.bo[buf_number].buftype ~= "" then
                        return false
                    end
                    return true
                end,
            },
        },
        keys = {
            { "bn", "<cmd>BufferLineCycleNext<cr>", desc = "bufferline next" },
            { "bp", "<cmd>BufferLineCyclePrev<cr>", desc = "bufferline prev" },
            {
                "bd",
                function()
                    require("snacks").bufdelete()
                end,
                desc = "buffer delete",
            },
            { "<leader>bl", "<cmd>BufferLineCloseRight<cr>", desc = "bufferline close right" },
            { "<leader>bh", "<cmd>BufferLineCloseLeft<cr>", desc = "bufferline close left" },
            { "<leader>bn", "<cmd>BufferLineMoveNext<cr>", desc = "bufferline move next" },
            { "<leader>bp", "<cmd>BufferLineMovePrev<cr>", desc = "bufferline move prev" },
        },
    },
    {
        -- scope.nvim 提供 tab 级别的 buffer 隔离
        "tiagovla/scope.nvim",
        event = "TabNew", -- tab 操作时加载
        config = function()
            require("scope").setup({
                hooks = {
                    pre_tab_enter = function()
                        -- 进入 tab 前的自定义逻辑
                    end,
                    post_tab_enter = function()
                        -- 进入 tab 后的自定义逻辑
                    end,
                },
            })
        end,
        keys = {
            { "<leader>bm", "<cmd>ScopeMoveBuf<cr>", desc = "Move buffer to another tab" },
            {
                "<leader>fb",
                function()
                    -- 使用 fzf-lua 显示当前 tab 的 buffers
                    require("fzf-lua").buffers({
                        fzf_opts = {
                            ["--header"] = "Buffers in current tab",
                        },
                    })
                end,
                desc = "Find buffers in current tab",
            },
        },
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "f-person/git-blame.nvim",
            "jinzhongjia/LspUI.nvim",
            {
                "AndreM222/copilot-lualine",
                dependencies = "zbirenbaum/copilot.lua",
            },
        },
        event = "UIEnter",
        opts = function()
            -- CodeCompanion Spinner 组件已被移除

            local special_filetypes = {
                "NvimTree",
                "Outline",
                "grug-far",
                "codecompanion",
                "snacks_terminal",
                -- dapui: 在这些窗口中隐藏状态栏/不渲染组件
                "dapui_scopes",
                "dapui_stacks",
                "dapui_watches",
                "dapui_breakpoints",
                "dapui_console",
                "dapui_repl",
                "dap-repl",
            }

            -- 检查当前 buffer 是否是特殊 filetype
            local function is_special_filetype()
                local ft = vim.bo.filetype
                for _, special_ft in ipairs(special_filetypes) do
                    if ft == special_ft then
                        return true
                    end
                end
                return false
            end

            return {
                options = {
                    globalstatus = false,
                    theme = "vscode",
                    disabled_filetypes = {
                        statusline = {
                            -- dapui 相关窗口禁用状态栏
                            "dapui_scopes",
                            "dapui_stacks",
                            "dapui_watches",
                            "dapui_breakpoints",
                            "dapui_console",
                            "dapui_repl",
                            "dap-repl",
                        },
                        winbar = {},
                    },
                },
                sections = {
                    lualine_a = {
                        {
                            "mode",
                            -- mode 组件在非 codecompanion filetype 时显示
                            cond = function()
                                return vim.bo.filetype ~= "codecompanion"
                            end,
                        },
                    },
                    lualine_b = {
                        -- CodeCompanion adapter 和 model 显示
                        {
                            function()
                                if vim.bo.filetype ~= "codecompanion" then
                                    return ""
                                end

                                local bufnr = vim.api.nvim_get_current_buf()
                                local metadata = _G.codecompanion_chat_metadata
                                    and _G.codecompanion_chat_metadata[bufnr]

                                if not metadata or not metadata.adapter then
                                    return ""
                                end

                                local adapter_info = metadata.adapter.name or ""
                                if metadata.adapter.model then
                                    adapter_info = adapter_info .. " (" .. metadata.adapter.model .. ")"
                                end

                                return "🤖 " .. adapter_info
                            end,
                            cond = function()
                                return vim.bo.filetype == "codecompanion"
                            end,
                            color = { fg = "#7aa2f7" },
                        },
                        {
                            "branch",
                            cond = function()
                                return not is_special_filetype()
                            end,
                        },
                        {
                            "diff",
                            cond = function()
                                return not is_special_filetype()
                            end,
                        },
                        {
                            "diagnostics",
                            cond = function()
                                return not is_special_filetype()
                            end,
                        },
                    },
                    lualine_c = {
                        {
                            function()
                                if is_insert then
                                    local signature = require("LspUI").api.signature()
                                    if not signature then
                                        return ""
                                    end
                                    if not signature.active_parameter then
                                        return signature.label
                                    end

                                    return signature.parameters[signature.active_parameter].label
                                elseif is_blame then
                                    return require("gitblame").get_current_blame_text()
                                end
                            end,
                            cond = function()
                                -- 特殊 filetype 不显示这个组件
                                if is_special_filetype() then
                                    return false
                                end

                                local mode_info = vim.api.nvim_get_mode()
                                local mode = mode_info["mode"]
                                is_insert = mode:find("i") ~= nil or mode:find("ic") ~= nil

                                local text = require("gitblame").get_current_blame_text()
                                if text then
                                    is_blame = text ~= ""
                                else
                                    is_blame = false
                                end

                                return is_insert or is_blame
                            end,
                        },
                        {
                            "filename",
                            cond = function()
                                return not is_special_filetype()
                            end,
                        },
                    },
                    lualine_x = {
                        -- CodeCompanion 请求处理状态（Spinner 已移除）
                        {
                            require("lazy.status").updates,
                            cond = function()
                                return require("lazy.status").has_updates() and not is_special_filetype()
                            end,
                            color = { fg = "#ff9e64" },
                        },
                        {
                            "copilot",
                            cond = function()
                                return not is_special_filetype()
                            end,
                        },
                        -- CodeCompanion 元数据显示（右侧显示 tokens, cycles, tools）
                        {
                            function()
                                if vim.bo.filetype ~= "codecompanion" then
                                    return ""
                                end

                                local bufnr = vim.api.nvim_get_current_buf()
                                local metadata = _G.codecompanion_chat_metadata
                                    and _G.codecompanion_chat_metadata[bufnr]

                                if not metadata then
                                    return ""
                                end

                                local parts = {}

                                -- 只显示 tokens, cycles, tools（adapter 和 model 已移到左侧）

                                -- 显示 tokens
                                if metadata.tokens and metadata.tokens > 0 then
                                    table.insert(parts, "🪙 " .. metadata.tokens)
                                end

                                -- 显示 cycles
                                if metadata.cycles and metadata.cycles > 0 then
                                    table.insert(parts, "🔄 " .. metadata.cycles)
                                end

                                -- 显示 tools
                                if metadata.tools and metadata.tools > 0 then
                                    table.insert(parts, "🔧 " .. metadata.tools)
                                end

                                return table.concat(parts, " │ ")
                            end,
                            cond = function()
                                return vim.bo.filetype == "codecompanion"
                            end,
                            color = { fg = "#7aa2f7" },
                        },
                        {
                            "encoding",
                            cond = function()
                                return not is_special_filetype()
                            end,
                        },
                        {
                            "fileformat",
                            cond = function()
                                return not is_special_filetype()
                            end,
                        },
                        {
                            "filetype",
                            -- 在 codecompanion filetype 时不显示
                            cond = function()
                                return vim.bo.filetype ~= "codecompanion"
                            end,
                        },
                    },
                    lualine_y = {
                        {
                            "progress",
                            cond = function()
                                return not is_special_filetype()
                            end,
                        },
                    },
                    lualine_z = {
                        {
                            "location",
                            cond = function()
                                return not is_special_filetype()
                            end,
                        },
                    },
                },
            }
        end,
    },
    {
        "anuvyklack/windows.nvim",
        event = "WinNew", -- 创建新窗口时加载
        dependencies = {
            "anuvyklack/middleclass",
        },
        opts = {
            ignore = {
                filetype = {
                    "NvimTree",
                    "undotree",
                    "Outline",
                    "codecompanion",
                    "grug-far",
                    "grug-far-history",
                    "Mundo",
                    -- DAP UI windows
                    "dapui_scopes",
                    "dapui_stacks",
                    "dapui_watches",
                    "dapui_breakpoints",
                    "dapui_console",
                    "dapui_repl",
                },
            },
        },
    },
    {
        "folke/trouble.nvim",
        cmd = "Trouble",
        dependencies = { "nvim-web-devicons" },
        opts = {
            win = { border = "rounded" },
            keys = {
                b = {
                    action = function(view)
                        view:filter({ buf = 0 }, { toggle = true })
                    end,
                    desc = "Toggle Current Buffer Filter",
                },
                s = {
                    action = function(view)
                        local f = view:get_filter("severity")
                        local severity = ((f and f.filter.severity or 0) + 1) % 5
                        view:filter({ severity = severity }, {
                            id = "severity",
                            template = "{hl:Title}Filter:{hl} {severity}",
                            del = severity == 0,
                        })
                    end,
                    desc = "Toggle Severity Filter",
                },
            },
            modes = {
                diagnostics_buffer = {
                    mode = "diagnostics",
                    filter = { buf = 0 },
                },
                errors = {
                    mode = "diagnostics",
                    filter = { severity = vim.diagnostic.severity.ERROR },
                },
                warnings = {
                    mode = "diagnostics",
                    filter = {
                        any = {
                            { severity = vim.diagnostic.severity.WARN },
                            { severity = vim.diagnostic.severity.ERROR },
                        },
                    },
                },
                symbols = {
                    mode = "lsp_document_symbols",
                    focus = false,
                    win = {
                        position = "right",
                        size = 0.3,
                    },
                },
                cascade = {
                    mode = "diagnostics",
                    filter = function(items)
                        local severity = vim.diagnostic.severity.HINT
                        for _, item in ipairs(items) do
                            severity = math.min(severity, item.severity)
                        end
                        return vim.tbl_filter(function(item)
                            return item.severity == severity
                        end, items)
                    end,
                },
                preview_float = {
                    mode = "diagnostics",
                    preview = {
                        type = "float",
                        relative = "editor",
                        border = "rounded",
                        position = { 0, -2 },
                        size = { width = 0.3, height = 0.3 },
                        zindex = 200,
                    },
                },
            },
        },
        keys = {
            { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (all)" },
            { "<leader>xb", "<cmd>Trouble diagnostics_buffer toggle<cr>", desc = "Diagnostics (buffer)" },
            { "<leader>xe", "<cmd>Trouble errors toggle<cr>", desc = "Errors only" },
            { "<leader>xw", "<cmd>Trouble warnings toggle<cr>", desc = "Warnings & errors" },
            { "<leader>xl", "<cmd>Trouble lsp toggle focus=false<cr>", desc = "LSP (definitions/refs)" },
            { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (document)" },
            { "<leader>xc", "<cmd>Trouble cascade toggle<cr>", desc = "Cascade diagnostics" },
            { "<leader>xf", "<cmd>Trouble preview_float toggle<cr>", desc = "Preview (float)" },
            { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix list" },
            { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location list" },
        },
    },
    {
        "folke/zen-mode.nvim",
        -- 命令触发
        cmd = "ZenMode",
        dependencies = {
            "folke/twilight.nvim",
            opts = {},
        },
        opts = {},
    },
    {
        "jeffkreeftmeijer/vim-numbertoggle",
        event = { "BufReadPost", "BufNewFile" },
    },
    {
        "nacro90/numb.nvim",
        event = "CmdlineEnter", -- 命令行输入时加载(用于跳转行号)
        opts = {
            number_only = true,
        },
    },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            local wk = require("which-key")
            
            -- 配置选项
            wk.setup({
                preset = "modern", -- classic / modern / helix
                delay = function(ctx)
                    return ctx.plugin and 0 or 200
                end,
                notify = true,
                sort = { "local", "order", "group", "alphanum", "mod" },
                expand = 0,
                icons = {
                    breadcrumb = "»",
                    separator = "➜",
                    group = "➕",
                    ellipsis = "…",
                    mappings = true,
                    colors = true,
                },
                win = {
                    no_overlap = true,
                    padding = { 1, 2 },
                    title = true,
                    title_pos = "center",
                    zindex = 1000,
                },
                layout = {
                    width = { min = 20, max = 50 },
                    spacing = 3,
                },
                keys = {
                    scroll_down = "<c-d>",
                    scroll_up = "<c-u>",
                },
                plugins = {
                    marks = true,
                    registers = true,
                    spelling = {
                        enabled = true,
                        suggestions = 20,
                    },
                    presets = {
                        operators = true,
                        motions = true,
                        text_objects = true,
                        windows = true,
                        nav = true,
                        z = true,
                        g = true,
                    },
                },
                show_help = true,
                show_keys = true,
                disable = {
                    ft = { "TelescopePrompt" },
                    bt = { "nofile" },
                },
            })

            -- 定义快捷键组和映射
            wk.add({
                -- ===== 窗口管理 (s = split) =====
                { "s", group = "split" },
                { "sv", "<CMD>vsp<CR>", desc = "Vertical split" },
                { "sh", "<CMD>sp<CR>", desc = "Horizontal split" },
                { "sc", "<C-w>c", desc = "Close current window" },
                { "so", "<C-w>o", desc = "Close other windows" },
                { "s=", "<C-w>=", desc = "Equalize window height" },
                { "s,", "<CMD>vertical resize -2<CR>", desc = "Decrease window width" },
                { "s.", "<CMD>vertical resize +2<CR>", desc = "Increase window width" },
                { "sj", "<CMD>resize +2<CR>", desc = "Increase window height" },
                { "sk", "<CMD>resize -2<CR>", desc = "Decrease window height" },

                -- ===== 窗口导航 (w = window) =====
                { "w", group = "window navigate" },
                { "wh", "<C-w>h", desc = "Go to left window" },
                { "wj", "<C-w>j", desc = "Go to lower window" },
                { "wk", "<C-w>k", desc = "Go to upper window" },
                { "wl", "<C-w>l", desc = "Go to right window" },

                -- ===== 快速查找 (Ctrl+p/f) =====
                { "<C-p>", "<cmd>FzfLua files<cr>", desc = "Find files" },
                { "<C-S-p>", function() require("fzf-lua").files({ fd_opts = [[--color=never --type f --hidden --follow --no-ignore]] }) end, desc = "Find files (all)" },
                { "<C-f>", "<cmd>FzfLua live_grep<cr>", desc = "Live grep" },
                { "<C-S-f>", function() require("fzf-lua").live_grep({ rg_opts = [[--column --line-number --no-heading --color=always --smart-case --max-columns=4096 --hidden --follow --no-ignore -e]] }) end, desc = "Live grep (all)" },

                -- ===== Ctrl 窗口大小调整 =====
                { "<C-Left>", "<CMD>vertical resize -2<CR>", desc = "Decrease window width" },
                { "<C-Right>", "<CMD>vertical resize +2<CR>", desc = "Increase window width" },
                { "<C-Down>", "<CMD>resize +2<CR>", desc = "Increase window height" },
                { "<C-Up>", "<CMD>resize -2<CR>", desc = "Decrease window height" },

                -- ===== Visual 模式编辑 =====
                { "<", "<gv", mode = "v", desc = "Indent left (keep selection)" },
                { ">", ">gv", mode = "v", desc = "Indent right (keep selection)" },
                { "J", "<CMD>move '>+1<CR>gv-gv", mode = "v", desc = "Move selection down" },
                { "K", "<CMD>move '<-2<CR>gv-gv", mode = "v", desc = "Move selection up" },

                -- ===== 复制粘贴 =====
                { "<C-c>", '"+y', mode = "v", desc = "Copy to system clipboard" },
                { "<C-x>", '"+d', mode = "v", desc = "Cut to system clipboard" },
                { "<C-v>", '<ESC>"+pa', mode = "i", desc = "Paste from system clipboard" },

                -- ===== 标签页管理 (leader-t = tabs) =====
                { "<leader>t", group = "tabs" },
                { "<leader>tn", "<CMD>tabnew<CR>", desc = "New tab" },
                { "<leader>tc", "<CMD>tabclose<CR>", desc = "Close tab" },
                { "<leader>to", "<CMD>tabonly<CR>", desc = "Close others" },
                { "<leader>th", "<CMD>tabprevious<CR>", desc = "Previous tab" },
                { "<leader>tl", "<CMD>tabnext<CR>", desc = "Next tab" },
                { "<leader>t1", "<CMD>tabn 1<CR>", desc = "Go to tab 1" },
                { "<leader>t2", "<CMD>tabn 2<CR>", desc = "Go to tab 2" },
                { "<leader>t3", "<CMD>tabn 3<CR>", desc = "Go to tab 3" },
                { "<leader>t4", "<CMD>tabn 4<CR>", desc = "Go to tab 4" },
                { "<leader>t5", "<CMD>tabn 5<CR>", desc = "Go to tab 5" },
                { "<leader>tt", "<cmd>FzfLua builtin<cr>", desc = "FzfLua builtins" },
                { "<leader>tr", "<cmd>FzfLua resume<cr>", desc = "Resume search" },
                { "<leader>tT", "<cmd>FzfLua tabs<cr>", desc = "Tabs list" },

                -- ===== 查找和搜索 (leader-f = find) =====
                { "<leader>f", group = "find" },
                { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Files" },
                { "<leader>fF", function() require("fzf-lua").files({ fd_opts = [[--color=never --type f --hidden --follow --no-ignore]] }) end, desc = "Files (all)" },
                { "<leader>fg", "<cmd>FzfLua live_grep_glob<cr>", desc = "Grep (glob)" },
                { "<leader>fG", "<cmd>FzfLua grep_project<cr>", desc = "Grep project" },

                -- ===== LSP 符号 (leader-s = search/symbols) =====
                { "<leader>s", group = "search/symbols" },
                { "<leader>ss", "<cmd>FzfLua lsp_document_symbols<cr>", desc = "Document symbols" },
                { "<leader>sw", "<cmd>FzfLua lsp_workspace_symbols<cr>", desc = "Workspace symbols" },
                { "<leader>sW", "<cmd>FzfLua lsp_live_workspace_symbols<cr>", desc = "Live symbols" },
                { "<leader>sf", "<cmd>FzfLua lsp_finder<cr>", desc = "LSP finder" },
                { "<leader>sd", "<cmd>FzfLua diagnostics_document<cr>", desc = "Document diagnostics" },
                { "<leader>sD", "<cmd>FzfLua diagnostics_workspace<cr>", desc = "Workspace diagnostics" },

                -- ===== 打开 (leader-o = open) =====
                { "<leader>o", group = "open" },
                { "<leader>ob", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
                { "<leader>oB", "<cmd>FzfLua oldfiles<cr>", desc = "Recent files" },
                { "<leader>ol", "<cmd>FzfLua lines<cr>", desc = "Lines (all)" },
                { "<leader>oL", "<cmd>FzfLua blines<cr>", desc = "Lines (buffer)" },
                { "<leader>oh", "<cmd>FzfLua help_tags<cr>", desc = "Help tags" },
                { "<leader>ok", "<cmd>FzfLua keymaps<cr>", desc = "Keymaps" },
                { "<leader>oc", "<cmd>FzfLua commands<cr>", desc = "Commands" },
                { "<leader>oC", "<cmd>FzfLua colorschemes<cr>", desc = "Colorschemes" },
                { "<leader>om", "<cmd>FzfLua marks<cr>", desc = "Marks" },
                { "<leader>oM", "<cmd>FzfLua man_pages<cr>", desc = "Man pages" },
                { "<leader>or", "<cmd>FzfLua registers<cr>", desc = "Registers" },
                { "<leader>oA", "<cmd>FzfLua autocmds<cr>", desc = "Autocmds" },
                { "<leader>oj", "<cmd>FzfLua jumps<cr>", desc = "Jumps" },
                { "<leader>oH", "<cmd>FzfLua command_history<cr>", desc = "Command history" },
                { "<leader>o/", "<cmd>FzfLua search_history<cr>", desc = "Search history" },
                { "<leader>oq", "<cmd>FzfLua quickfix<cr>", desc = "Quickfix" },
                { "<leader>oQ", "<cmd>FzfLua quickfix_stack<cr>", desc = "Quickfix history" },

                -- ===== Git (leader-g = git) =====
                { "<leader>g", group = "git" },
                { "<leader>gb", "<cmd>FzfLua git_branches<cr>", desc = "Branches" },
                { "<leader>gc", "<cmd>FzfLua git_commits<cr>", desc = "Commits" },
                { "<leader>gC", "<cmd>FzfLua git_bcommits<cr>", desc = "Buffer commits" },
                { "<leader>gs", "<cmd>FzfLua git_status<cr>", desc = "Status" },
                { "<leader>gS", "<cmd>FzfLua git_stash<cr>", desc = "Stash" },

                -- ===== 搜索内容 (leader-/ = search) =====
                { "<leader>/", "<cmd>FzfLua live_grep<cr>", desc = "Live grep" },
                { "<leader>?", "<cmd>FzfLua live_grep_glob<cr>", desc = "Grep (glob)" },
                { "<leader>*", "<cmd>FzfLua grep_cword<cr>", desc = "Grep cursor word" },

                -- ===== 会话 (leader-q = quit/session) =====
                { "<leader>q", group = "session" },
                { "<leader>qs", function() require("persistence").load() end, desc = "Restore session" },
                { "<leader>qS", function() require("persistence").select() end, desc = "Select session" },
                { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Last session" },
                { "<leader>qd", function() require("persistence").stop() end, desc = "Disable session autosave" },

                -- ===== 代码分割/合并 (leader-m/j/s = treesj) =====
                { "<leader>m", function() require("treesj").toggle() end, desc = "Toggle split/join" },
                { "<leader>j", function() require("treesj").join() end, desc = "Join code block" },
                { "<leader>s", function() require("treesj").split() end, desc = "Split code block" },

                -- ===== 问题诊断 (leader-x = troubleshooting) =====
                { "<leader>x", group = "troubleshoot" },
                { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (all)" },
                { "<leader>xb", "<cmd>Trouble diagnostics_buffer toggle<cr>", desc = "Diagnostics (buffer)" },
                { "<leader>xe", "<cmd>Trouble errors toggle<cr>", desc = "Errors only" },
                { "<leader>xw", "<cmd>Trouble warnings toggle<cr>", desc = "Warnings & errors" },
                { "<leader>xl", "<cmd>Trouble lsp toggle focus=false<cr>", desc = "LSP (refs/defs)" },
                { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (doc)" },
                { "<leader>xc", "<cmd>Trouble cascade toggle<cr>", desc = "Cascade (severity)" },
                { "<leader>xf", "<cmd>Trouble preview_float toggle<cr>", desc = "Preview (float)" },
                { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix list" },
                { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location list" },

                -- ===== 帮助 (leader-h = help) =====
                { "<leader>h", function() require("which-key").show({ global = false }) end, desc = "Keymaps", mode = "n" },
            })
        end,
        keys = {},
    },
    {
        -- 这个插件也不错
        "OXY2DEV/markview.nvim",
        enabled = false,
        opts = {
            preview = {
                filetypes = { "markdown", "codecompanion", "LspUI_hover" },
                ignore_buftypes = {},
            },
        },
    },
    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
        ft = { "markdown", "codecompanion", "LspUI_hover" },
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {
            checkbox = {
                unchecked = { icon = "✘ " },
                checked = { icon = "✔ " },
                custom = { todo = { rendered = "◯ " } },
            },
            html = {
                enabled = true,
                tag = {
                    buf = { icon = " ", highlight = "CodeCompanionChatVariable" },
                    file = { icon = " ", highlight = "CodeCompanionChatVariable" },
                    help = { icon = "󰘥 ", highlight = "CodeCompanionChatVariable" },
                    image = { icon = " ", highlight = "CodeCompanionChatVariable" },
                    symbols = { icon = " ", highlight = "CodeCompanionChatVariable" },
                    url = { icon = "󰖟 ", highlight = "CodeCompanionChatVariable" },
                    var = { icon = " ", highlight = "CodeCompanionChatVariable" },
                    tool = { icon = " ", highlight = "CodeCompanionChatTool" },
                    user = { icon = " ", highlight = "CodeCompanionChatTool" },
                    group = { icon = " ", highlight = "CodeCompanionChatToolGroup" },
                    memory = { icon = "󰍛 ", highlight = "CodeCompanionChatVariable" },
                },
            },
        },
    },
    {
        "hat0uma/csvview.nvim",
        cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
        opts = {},
    },
    {
        "yorickpeterse/nvim-window",
        keys = {
            { "<leader>wj", "<cmd>lua require('nvim-window').pick()<cr>", desc = "nvim-window: Jump to window" },
        },
        config = true,
    },
}
