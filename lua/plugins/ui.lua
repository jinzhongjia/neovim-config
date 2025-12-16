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
                    {
                        filetype = "fyler",
                        text = " FILE MANAGER",
                        text_align = "center",
                        separator = true,
                    },
                    -- Neogit status buffer
                    {
                        filetype = "NeogitStatus",
                        text = " NEOGIT STATUS",
                        text_align = "center",
                        separator = true,
                    },
                    -- Neogit commit view
                    {
                        filetype = "NeogitCommitView",
                        text = " COMMIT VIEW",
                        text_align = "center",
                        separator = true,
                    },
                    -- Neogit diff view
                    {
                        filetype = "NeogitDiffView",
                        text = " DIFF VIEW",
                        text_align = "center",
                        separator = true,
                    },
                    -- Git commit message editor
                    {
                        filetype = "gitcommit",
                        text = " COMMIT MESSAGE",
                        text_align = "center",
                        separator = true,
                    },
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
                -- opencode: 使用自定义扩展
                "opencode",
                "opencode_output",
                -- neogit: git 相关窗口使用简化状态栏
                "NeogitStatus",
                "NeogitCommitView",
                "NeogitDiffView",
                "gitcommit",
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

            -- OpenCode extension for lualine
            -- 为 opencode 和 opencode_output filetype 提供美化的状态栏
            -- Section A: 显示当前窗口类型（Input/Output）
            -- Section B: 显示会话名称
            -- Section C: 显示 Provider 和 Model
            -- Section X: 显示 Token 使用量
            local opencode_extension = {
                sections = {
                    lualine_a = {
                        {
                            function()
                                local ft = vim.bo.filetype
                                if ft == "opencode" then
                                    return " OpenCode Input"
                                elseif ft == "opencode_output" then
                                    return " OpenCode Output"
                                end
                                return ""
                            end,
                            color = function()
                                local ft = vim.bo.filetype
                                if ft == "opencode" then
                                    return { fg = "#ffffff", bg = "#7aa2f7", gui = "bold" }
                                elseif ft == "opencode_output" then
                                    return { fg = "#ffffff", bg = "#9ece6a", gui = "bold" }
                                end
                            end,
                        },
                    },
                    lualine_b = {
                        {
                            function()
                                -- 显示当前会话信息
                                local ok, opencode = pcall(require, "opencode")
                                if ok and opencode.get_current_session then
                                    local session = opencode.get_current_session()
                                    if session and session.name then
                                        return " " .. session.name
                                    end
                                end
                                return ""
                            end,
                            color = { fg = "#bb9af7" },
                        },
                    },
                    lualine_c = {
                        {
                            function()
                                -- 显示 provider/model 信息
                                local ok, opencode = pcall(require, "opencode")
                                if ok and opencode.get_config then
                                    local config = opencode.get_config()
                                    if config and config.provider then
                                        local provider = config.provider
                                        local model = config.model or ""
                                        if model ~= "" then
                                            return string.format(" %s (%s)", provider, model)
                                        else
                                            return string.format(" %s", provider)
                                        end
                                    end
                                end
                                return ""
                            end,
                            color = { fg = "#7dcfff" },
                        },
                    },
                    lualine_x = {
                        {
                            function()
                                -- 显示 token 使用情况（如果可用）
                                local ok, opencode = pcall(require, "opencode")
                                if ok and opencode.get_token_usage then
                                    local usage = opencode.get_token_usage()
                                    if usage and usage.total then
                                        return string.format("󰔷 %d", usage.total)
                                    end
                                end
                                return ""
                            end,
                            color = { fg = "#e0af68" },
                        },
                    },
                    lualine_y = {
                        {
                            "progress",
                            color = { fg = "#c0caf5" },
                        },
                    },
                    lualine_z = {
                        {
                            "location",
                            color = { fg = "#c0caf5" },
                        },
                    },
                },
                filetypes = { "opencode", "opencode_output" },
            }

            -- Neogit/Git extension for lualine
            -- 为 Neogit 和 gitcommit filetype 提供美化的状态栏
            local neogit_extension = {
                sections = {
                    lualine_a = {
                        {
                            function()
                                local ft = vim.bo.filetype
                                if ft == "NeogitStatus" then
                                    return " Neogit Status"
                                elseif ft == "NeogitCommitView" then
                                    return " Commit View"
                                elseif ft == "NeogitDiffView" then
                                    return " Diff View"
                                elseif ft == "gitcommit" then
                                    return " Commit Message"
                                end
                                return ""
                            end,
                            color = function()
                                local ft = vim.bo.filetype
                                if ft == "NeogitStatus" then
                                    return { fg = "#ffffff", bg = "#f7768e", gui = "bold" } -- 红色
                                elseif ft == "NeogitCommitView" then
                                    return { fg = "#ffffff", bg = "#bb9af7", gui = "bold" } -- 紫色
                                elseif ft == "NeogitDiffView" then
                                    return { fg = "#1a1b26", bg = "#e0af68", gui = "bold" } -- 橙色/黄色
                                elseif ft == "gitcommit" then
                                    return { fg = "#1a1b26", bg = "#9ece6a", gui = "bold" } -- 绿色
                                end
                            end,
                        },
                    },
                    lualine_b = {
                        {
                            function()
                                -- 显示当前 git 分支
                                local branch = vim.fn.system("git branch --show-current 2>/dev/null"):gsub("\n", "")
                                if branch and branch ~= "" then
                                    return " " .. branch
                                end
                                return ""
                            end,
                            color = { fg = "#e0af68" },
                        },
                    },
                    lualine_c = {
                        {
                            function()
                                -- 显示当前仓库名称
                                local repo = vim.fn
                                    .system("basename $(git rev-parse --show-toplevel 2>/dev/null) 2>/dev/null")
                                    :gsub("\n", "")
                                if repo and repo ~= "" then
                                    return " " .. repo
                                end
                                return ""
                            end,
                            color = { fg = "#7aa2f7" },
                        },
                    },
                    lualine_x = {
                        {
                            function()
                                -- gitcommit: 显示行数和字符统计
                                if vim.bo.filetype == "gitcommit" then
                                    local lines = vim.fn.line("$")
                                    local chars = vim.fn.wordcount().chars
                                    return string.format(" %d lines │  %d chars", lines, chars)
                                end
                                return ""
                            end,
                            color = { fg = "#c0caf5" },
                        },
                    },
                    lualine_y = {
                        {
                            "progress",
                            color = { fg = "#c0caf5" },
                        },
                    },
                    lualine_z = {
                        {
                            "location",
                            color = { fg = "#c0caf5" },
                        },
                    },
                },
                filetypes = { "NeogitStatus", "NeogitCommitView", "NeogitDiffView", "gitcommit" },
            }

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
                extensions = { opencode_extension, neogit_extension },
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

                                -- 检查当前 buffer 是否是真实文件
                                local bufnr = vim.api.nvim_get_current_buf()
                                local bufname = vim.api.nvim_buf_get_name(bufnr)
                                local buftype = vim.bo[bufnr].buftype

                                -- 只有当 buffer 是普通文件（buftype 为空）、有文件名且文件实际存在时才显示相关信息
                                local is_real_file = buftype == ""
                                    and bufname ~= ""
                                    and vim.fn.filereadable(bufname) == 1

                                -- 只在真实文件中检查 insert 模式和 git blame
                                if is_real_file then
                                    local mode_info = vim.api.nvim_get_mode()
                                    local mode = mode_info["mode"]
                                    is_insert = mode:find("i") ~= nil or mode:find("ic") ~= nil

                                    local text = require("gitblame").get_current_blame_text()
                                    if text then
                                        is_blame = text ~= ""
                                    else
                                        is_blame = false
                                    end
                                else
                                    is_insert = false
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
        enabled = false,
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
                    -- opencode
                    "opencode",
                    "opencode_output",
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

                -- ===== 快速查找 (Ctrl+p/f) - 由 snacks.nvim 的 keys 配置定义 =====
                -- 注意: 这些快捷键已移至 lua/plugins/tools.lua 的 snacks.nvim keys 中

                -- ===== Ctrl 窗口大小调整 =====
                { "<C-Left>", "<cmd>vertical resize -2<cr>", desc = "Decrease window width" },
                { "<C-Right>", "<cmd>vertical resize +2<cr>", desc = "Increase window width" },
                { "<C-Down>", "<cmd>resize +2<cr>", desc = "Increase window height" },
                { "<C-Up>", "<cmd>resize -2<cr>", desc = "Decrease window height" },

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
                { "<leader>tn", "<cmd>tabnew<cr>", desc = "New tab" },
                { "<leader>tc", "<cmd>tabclose<cr>", desc = "Close tab" },
                { "<leader>to", "<cmd>tabonly<cr>", desc = "Close others" },
                { "<leader>th", "<cmd>tabprevious<cr>", desc = "Previous tab" },
                { "<leader>tl", "<cmd>tabnext<cr>", desc = "Next tab" },
                { "<leader>t1", "<cmd>tabn 1<cr>", desc = "Go to tab 1" },
                { "<leader>t2", "<cmd>tabn 2<cr>", desc = "Go to tab 2" },
                { "<leader>t3", "<cmd>tabn 3<cr>", desc = "Go to tab 3" },
                { "<leader>t4", "<cmd>tabn 4<cr>", desc = "Go to tab 4" },
                { "<leader>t5", "<cmd>tabn 5<cr>", desc = "Go to tab 5" },
                -- 注意: <leader>tt 和 <leader>tr 已在 snacks.nvim keys 中定义

                -- ===== 查找和搜索 (leader-f = find) =====
                { "<leader>f", group = "find" },
                -- 注意: 所有 <leader>f* 快捷键已在 snacks.nvim keys 中定义

                -- ===== LSP 符号 (leader-s = search/symbols) =====
                { "<leader>s", group = "search/symbols" },
                -- 注意: 所有 <leader>s* 快捷键已在 snacks.nvim keys 中定义

                -- ===== 打开 (leader-o = open) =====
                { "<leader>o", group = "open" },
                -- 注意: 所有 <leader>o* 快捷键已在 snacks.nvim keys 中定义

                -- ===== Git (leader-g = git) =====
                { "<leader>g", group = "git" },
                -- 注意: 所有 <leader>g* 快捷键已在 snacks.nvim keys 中定义

                -- ===== 搜索内容 (leader-/ = search) =====
                -- 注意: <leader>/, <leader>* 快捷键已在 snacks.nvim keys 中定义

                -- ===== 会话 (leader-q = quit/session) =====
                { "<leader>q", group = "session" },
                {
                    "<leader>qs",
                    function()
                        require("persistence").load()
                    end,
                    desc = "Restore session",
                },
                {
                    "<leader>qS",
                    function()
                        require("persistence").select()
                    end,
                    desc = "Select session",
                },
                {
                    "<leader>ql",
                    function()
                        require("persistence").load({ last = true })
                    end,
                    desc = "Last session",
                },
                {
                    "<leader>qd",
                    function()
                        require("persistence").stop()
                    end,
                    desc = "Disable session autosave",
                },

                -- ===== 代码分割/合并 (leader-m/j/s = treesj) =====
                {
                    "<leader>m",
                    function()
                        require("treesj").toggle()
                    end,
                    desc = "Toggle split/join",
                },
                {
                    "<leader>j",
                    function()
                        require("treesj").join()
                    end,
                    desc = "Join code block",
                },
                {
                    "<leader>s",
                    function()
                        require("treesj").split()
                    end,
                    desc = "Split code block",
                },

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
                {
                    "<leader>h",
                    function()
                        require("which-key").show({ global = false })
                    end,
                    desc = "Keymaps",
                    mode = "n",
                },
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
        ft = { "markdown", "codecompanion", "LspUI_hover", "Avante", "copilot-chat", "opencode_output" },
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {
            -- 启用所有需要的 filetype（需与 ft 保持一致）
            file_types = { "markdown", "codecompanion", "LspUI_hover", "Avante", "copilot-chat", "opencode_output" },
            -- 启用 anti-conceal：光标所在行显示原始 markdown 语法
            anti_conceal = {
                enabled = true,
                -- 光标上下各显示 0 行的原始语法（仅当前行）
                above = 0,
                below = 0,
            },
            -- 启用 LSP completions 支持（用于 checkbox 和 callouts 补全）
            completions = {
                lsp = { enabled = true },
            },
            -- Checkbox 自定义样式
            checkbox = {
                unchecked = { icon = "✘ " },
                checked = { icon = "✔ " },
                custom = { todo = { rendered = "◯ " } },
            },
            -- HTML 标签渲染（保留原有配置）
            html = {
                enabled = true,
                tag = {
                    buf = { icon = " ", highlight = "CodeCompanionChatVariable" },
                    file = { icon = " ", highlight = "CodeCompanionChatVariable" },
                    help = { icon = "󰾚 ", highlight = "CodeCompanionChatVariable" },
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
            -- 针对特殊 buffer 类型的优化
            overrides = {
                buftype = {
                    -- 为 nofile 类型的 buffer（如 codecompanion chat）优化
                    nofile = {
                        render_modes = true, -- 在所有模式下渲染
                        sign = { enabled = false }, -- 禁用 sign column（chat buffer 不需要）
                        padding = { highlight = "NormalFloat" }, -- 使用浮动窗口背景色
                    },
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
