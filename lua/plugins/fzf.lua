return
--- @type LazySpec
{
    {
        "ibhagwan/fzf-lua",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        event = "VeryLazy",
        config = function()
            local fzf = require("fzf-lua")

            -- 检测操作系统
            local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1

            fzf.setup({
                -- 全局窗口配置
                winopts = {
                    height = 0.9,
                    width = 0.9,
                    row = 0.5,
                    col = 0.5,
                    border = "rounded",
                    preview = {
                        -- 使用 bat 进行语法高亮预览
                        default = "bat",
                        border = "border",
                        wrap = "nowrap",
                        hidden = "nohidden",
                        vertical = "down:45%",
                        horizontal = "right:60%",
                        layout = "flex",
                        flip_columns = 120,
                        scrollbar = "float",
                        scrolloff = -2,
                        delay = 100,
                        winopts = {
                            number = true,
                            relativenumber = false,
                            cursorline = true,
                            cursorlineopt = "both",
                            cursorcolumn = false,
                            signcolumn = "no",
                            list = false,
                            foldenable = false,
                            foldmethod = "manual",
                        },
                    },
                },

                -- 快捷键配置
                keymap = {
                    builtin = {
                        ["<F1>"] = "toggle-help",
                        ["<F2>"] = "toggle-fullscreen",
                        ["<F3>"] = "toggle-preview-wrap",
                        ["<F4>"] = "toggle-preview",
                        ["<F5>"] = "toggle-preview-cw",
                        ["<C-d>"] = "preview-page-down",
                        ["<C-u>"] = "preview-page-up",
                        ["<S-down>"] = "preview-page-down",
                        ["<S-up>"] = "preview-page-up",
                    },
                    fzf = {
                        ["ctrl-z"] = "abort",
                        ["ctrl-u"] = "unix-line-discard",
                        ["ctrl-f"] = "half-page-down",
                        ["ctrl-b"] = "half-page-up",
                        ["ctrl-a"] = "beginning-of-line",
                        ["ctrl-e"] = "end-of-line",
                        ["alt-a"] = "toggle-all",
                        ["ctrl-q"] = "select-all+accept",
                    },
                },

                -- FZF 原生选项
                fzf_opts = {
                    ["--ansi"] = true,
                    ["--info"] = "inline-right", -- fzf >= v0.42
                    -- Windows 上 fzf < 0.21.0 不支持 --height，使用 100% 确保兼容
                    ["--height"] = "100%",
                    ["--layout"] = "reverse",
                    ["--border"] = "none",
                    ["--highlight-line"] = true, -- fzf >= v0.53
                    ["--padding"] = "0,1",
                    ["--margin"] = "0",
                    -- Windows 不需要设置 TERM 环境变量，cmd.exe 和 PowerShell 默认不设置
                },

                -- Previewers 配置
                previewers = {
                    bat = {
                        cmd = "bat",
                        args = "--color=always --style=numbers,changes",
                        theme = "default", -- bat 主题
                    },
                    builtin = {
                        syntax = true,
                        syntax_limit_l = 0,
                        syntax_limit_b = 1024 * 1024, -- 1MB
                        limit_b = 1024 * 1024 * 10, -- 10MB
                        treesitter = { enabled = true },
                        extensions = {
                            -- 可以为特殊文件类型配置预览器
                            ["png"] = { "chafa" },
                            ["jpg"] = { "chafa" },
                        },
                    },
                    git_diff = {
                        -- delta 会被自动检测，可以通过 pager = false 禁用
                        -- pager = false,
                        -- 跨平台兼容：
                        -- Windows: 不使用 $FZF_PREVIEW_COLUMNS（shell 变量在 cmd.exe 中不可用）
                        -- Unix: 使用环境变量动态调整宽度
                        pager = is_windows and "delta --line-numbers --diff-so-fancy"
                            or [[delta --width=$FZF_PREVIEW_COLUMNS --line-numbers --diff-so-fancy]],
                    },
                },

                -- 文件查找配置
                files = {
                    prompt = "Files❯ ",
                    multiprocess = true,
                    file_icons = true,
                    git_icons = false,
                    color_icons = true,
                    -- Windows 兼容性说明：
                    -- 1. 优先使用 fd（跨平台，速度快）
                    -- 2. 其次使用 rg --files（ripgrep，Windows 原生支持）
                    -- 3. 最后使用 find（Windows 上可能需要 Git Bash/MSYS2）
                    -- 注意：Windows cmd.exe 会启动这些命令，确保它们在 PATH 中
                    fd_opts = [[--color=never --type f --hidden --follow --exclude .git]],
                    rg_opts = [[--color=never --files --hidden --follow -g '!.git']],
                    -- Windows 上如果使用 find，需要确保是 Unix-like find，而非 Windows 自带的 FIND.EXE
                    -- find_opts = [[-type f -not -path '*/\.git/*']],  -- 仅在有 Unix find 时使用
                    actions = {
                        ["enter"] = require("fzf-lua.actions").file_edit_or_qf,
                        ["ctrl-s"] = require("fzf-lua.actions").file_split,
                        ["ctrl-v"] = require("fzf-lua.actions").file_vsplit,
                        ["ctrl-t"] = require("fzf-lua.actions").file_tabedit,
                        ["alt-q"] = require("fzf-lua.actions").file_sel_to_qf,
                        ["alt-l"] = require("fzf-lua.actions").file_sel_to_ll,
                    },
                },

                -- Grep 配置
                grep = {
                    prompt = "Rg❯ ",
                    input_prompt = "Grep For❯ ",
                    multiprocess = true,
                    file_icons = true,
                    git_icons = false,
                    color_icons = true,
                    rg_opts = [[--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e]],
                    actions = {
                        ["enter"] = require("fzf-lua.actions").file_edit_or_qf,
                        ["ctrl-s"] = require("fzf-lua.actions").file_split,
                        ["ctrl-v"] = require("fzf-lua.actions").file_vsplit,
                        ["ctrl-t"] = require("fzf-lua.actions").file_tabedit,
                        ["alt-q"] = require("fzf-lua.actions").file_sel_to_qf,
                        ["alt-l"] = require("fzf-lua.actions").file_sel_to_ll,
                    },
                },

                -- Live grep 配置
                live_grep = {
                    prompt = "Live Grep❯ ",
                    multiprocess = true,
                    file_icons = true,
                    git_icons = false,
                    color_icons = true,
                    rg_glob = true, -- enable glob parsing
                    glob_flag = "--iglob",
                    glob_separator = "%s%-%-",
                    -- 可选：开始时隐藏预览，避免空结果时的错误
                    -- winopts = { preview = { hidden = "hidden" } },
                },

                -- Buffers 配置
                buffers = {
                    prompt = "Buffers❯ ",
                    file_icons = true,
                    color_icons = true,
                    sort_lastused = true,
                    show_unloaded = true,
                    cwd_only = false,
                    actions = {
                        ["enter"] = require("fzf-lua.actions").buf_edit,
                        ["ctrl-s"] = require("fzf-lua.actions").buf_split,
                        ["ctrl-v"] = require("fzf-lua.actions").buf_vsplit,
                        ["ctrl-t"] = require("fzf-lua.actions").buf_tabedit,
                        ["ctrl-x"] = { fn = require("fzf-lua.actions").buf_del, reload = true },
                    },
                },

                -- Git 配置
                git = {
                    files = {
                        prompt = "GitFiles❯ ",
                        cmd = "git ls-files --exclude-standard",
                        multiprocess = true,
                        file_icons = true,
                        git_icons = true,
                        color_icons = true,
                    },
                    status = {
                        prompt = "GitStatus❯ ",
                        cmd = "git -c color.status=false --no-optional-locks status --porcelain=v1 -u",
                        multiprocess = true,
                        file_icons = true,
                        git_icons = true,
                        color_icons = true,
                        previewer = "git_diff",
                        -- delta 自动检测，也可以显式配置
                        -- preview_pager = "delta --width=$FZF_PREVIEW_COLUMNS",
                        actions = {
                            ["right"] = { fn = require("fzf-lua.actions").git_unstage, reload = true },
                            ["left"] = { fn = require("fzf-lua.actions").git_stage, reload = true },
                            ["ctrl-x"] = { fn = require("fzf-lua.actions").git_reset, reload = true },
                        },
                    },
                    commits = {
                        prompt = "Commits❯ ",
                        cmd = [[git log --color --pretty=format:"%C(yellow)%h%Creset ]]
                            .. [[%Cgreen(%><(12)%cr%><|(12))%Creset %s %C(blue)<%an>%Creset"]],
                        preview = "git show --color {1}",
                        -- delta 会自动用于美化 commit 预览
                        -- preview_pager = "delta --width=$FZF_PREVIEW_COLUMNS",
                        actions = {
                            ["enter"] = require("fzf-lua.actions").git_checkout,
                            ["ctrl-y"] = {
                                fn = require("fzf-lua.actions").git_yank_commit,
                                exec_silent = true,
                            },
                        },
                    },
                    bcommits = {
                        prompt = "BCommits❯ ",
                        cmd = [[git log --color --pretty=format:"%C(yellow)%h%Creset ]]
                            .. [[%Cgreen(%><(12)%cr%><|(12))%Creset %s %C(blue)<%an>%Creset" {file}]],
                        preview = "git show --color {1} -- {file}",
                        -- delta 会自动用于美化 buffer commit 预览
                        -- preview_pager = "delta --width=$FZF_PREVIEW_COLUMNS",
                        actions = {
                            ["enter"] = require("fzf-lua.actions").git_buf_edit,
                            ["ctrl-s"] = require("fzf-lua.actions").git_buf_split,
                            ["ctrl-v"] = require("fzf-lua.actions").git_buf_vsplit,
                            ["ctrl-t"] = require("fzf-lua.actions").git_buf_tabedit,
                        },
                    },
                    branches = {
                        prompt = "Branches❯ ",
                        cmd = "git branch --all --color",
                        preview = [[git log --graph --pretty=oneline --abbrev-commit --color {1}]],
                        actions = {
                            ["enter"] = require("fzf-lua.actions").git_switch,
                            ["ctrl-x"] = {
                                fn = require("fzf-lua.actions").git_branch_del,
                                reload = true,
                            },
                            ["ctrl-a"] = {
                                fn = require("fzf-lua.actions").git_branch_add,
                                field_index = "{q}",
                                reload = true,
                            },
                        },
                    },
                },

                -- LSP 配置
                lsp = {
                    prompt_postfix = "❯ ",
                    file_icons = true,
                    color_icons = true,
                    git_icons = false,
                    jump_to_single_result = true,
                    jump_to_single_result_action = require("fzf-lua.actions").file_edit,
                    includeDeclaration = true,
                    symbols = {
                        symbol_style = 1,
                        symbol_icons = {
                            File = "󰈙",
                            Module = "",
                            Namespace = "󰦮",
                            Package = "",
                            Class = "󰆧",
                            Method = "󰊕",
                            Property = "",
                            Field = "",
                            Constructor = "",
                            Enum = "",
                            Interface = "",
                            Function = "󰊕",
                            Variable = "󰀫",
                            Constant = "󰏿",
                            String = "",
                            Number = "󰎠",
                            Boolean = "󰨙",
                            Array = "󱡠",
                            Object = "",
                            Key = "󰌋",
                            Null = "󰟢",
                            EnumMember = "",
                            Struct = "󰆼",
                            Event = "",
                            Operator = "󰆕",
                            TypeParameter = "󰗴",
                        },
                        symbol_hl = function(s)
                            return "@" .. s:lower()
                        end,
                    },
                    code_actions = {
                        prompt = "Code Actions❯ ",
                        async_or_timeout = 5000,
                        previewer = "codeaction",
                    },
                },

                -- 旧文件配置（替代 frecency）
                oldfiles = {
                    prompt = "History❯ ",
                    cwd_only = false,
                    stat_file = true,
                    include_current_session = false,
                    file_icons = true,
                    color_icons = true,
                },

                -- Quickfix & Loclist
                quickfix = {
                    prompt = "Quickfix❯ ",
                    file_icons = true,
                    color_icons = true,
                },
                loclist = {
                    prompt = "Location List❯ ",
                    file_icons = true,
                    color_icons = true,
                },

                -- Help tags
                helptags = {
                    prompt = "Help❯ ",
                    actions = {
                        ["enter"] = require("fzf-lua.actions").help,
                        ["ctrl-s"] = require("fzf-lua.actions").help,
                        ["ctrl-v"] = require("fzf-lua.actions").help_vert,
                        ["ctrl-t"] = require("fzf-lua.actions").help_tab,
                    },
                },

                -- Man pages（仅在非 Windows 系统启用）
                manpages = not is_windows and {
                    prompt = "Man❯ ",
                    actions = {
                        ["enter"] = require("fzf-lua.actions").man,
                        ["ctrl-s"] = require("fzf-lua.actions").man,
                        ["ctrl-v"] = require("fzf-lua.actions").man_vert,
                        ["ctrl-t"] = require("fzf-lua.actions").man_tab,
                    },
                } or nil,

                -- 颜色方案
                colorschemes = {
                    prompt = "Colorschemes❯ ",
                    live_preview = true,
                    actions = {
                        ["enter"] = require("fzf-lua.actions").colorscheme,
                    },
                    winopts = { height = 0.55, width = 0.30 },
                },

                -- Keymaps
                keymaps = {
                    prompt = "Keymaps❯ ",
                    winopts = {
                        preview = { layout = "vertical" },
                    },
                    actions = {
                        ["enter"] = require("fzf-lua.actions").keymap_apply,
                        ["ctrl-s"] = require("fzf-lua.actions").keymap_split,
                        ["ctrl-v"] = require("fzf-lua.actions").keymap_vsplit,
                        ["ctrl-t"] = require("fzf-lua.actions").keymap_tabedit,
                    },
                },

                -- 预设主题（可选，注释掉使用默认）
                -- fzf_colors = {
                --     ["fg"] = { "fg", "CursorLine" },
                --     ["bg"] = { "bg", "Normal" },
                --     ["hl"] = { "fg", "Comment" },
                --     ["fg+"] = { "fg", "Normal" },
                --     ["bg+"] = { "bg", "CursorLine" },
                --     ["hl+"] = { "fg", "Statement" },
                --     ["info"] = { "fg", "PreProc" },
                --     ["prompt"] = { "fg", "Conditional" },
                --     ["pointer"] = { "fg", "Exception" },
                --     ["marker"] = { "fg", "Keyword" },
                --     ["spinner"] = { "fg", "Label" },
                --     ["header"] = { "fg", "Comment" },
                --     ["gutter"] = { "bg", "Normal" },
                -- },
            })

            -- 注意：vim.ui.select 由 snacks.nvim 提供，不使用 fzf-lua
            -- 如果需要使用 fzf-lua 作为 vim.ui.select，取消下面的注释
            -- fzf.register_ui_select()
        end,
        keys = function()
            local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1

            local keys = {
                -- 文件查找
                { "<C-p>", "<cmd>FzfLua files<cr>", desc = "Find files" },
                {
                    "<C-S-p>",
                    function()
                        require("fzf-lua").files({
                            fd_opts = [[--color=never --type f --hidden --follow --no-ignore]],
                        })
                    end,
                    desc = "Find files (include ignored)",
                },

                -- 搜索
                { "<C-f>", "<cmd>FzfLua live_grep<cr>", desc = "Live grep" },
                {
                    "<C-S-f>",
                    function()
                        require("fzf-lua").live_grep({
                            rg_opts = [[--column --line-number --no-heading --color=always --smart-case --max-columns=4096 --hidden --follow --no-ignore -e]],
                        })
                    end,
                    desc = "Live grep (include ignored)",
                },
                { "<leader>*", "<cmd>FzfLua grep_cword<cr>", desc = "Grep cursor word" },
                { "<leader>*", "<cmd>FzfLua grep_visual<cr>", mode = "v", desc = "Grep visual selection" },
                { "<leader>tg", "<cmd>FzfLua live_grep_glob<cr>", desc = "Live grep with glob" },
                { "<leader>tG", "<cmd>FzfLua grep_project<cr>", desc = "Grep project" },

                -- 缓冲区和历史
                { "<leader>tb", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
                { "<leader>to", "<cmd>FzfLua oldfiles<cr>", desc = "Recent files" },
                { "<leader>tL", "<cmd>FzfLua blines<cr>", desc = "Buffer lines" },
                { "<leader>tl", "<cmd>FzfLua lines<cr>", desc = "All lines" },

                -- Git
                { "<leader>tgb", "<cmd>FzfLua git_branches<cr>", desc = "Git branches" },
                { "<leader>tgc", "<cmd>FzfLua git_commits<cr>", desc = "Git commits" },
                { "<leader>tgs", "<cmd>FzfLua git_status<cr>", desc = "Git status" },
                { "<leader>tgd", "<cmd>FzfLua git_bcommits<cr>", desc = "Buffer commits" },
                { "<leader>tgh", "<cmd>FzfLua git_stash<cr>", desc = "Git stash" },

                -- LSP
                { "<leader>ss", "<cmd>FzfLua lsp_document_symbols<cr>", desc = "Document symbols" },
                { "<leader>sw", "<cmd>FzfLua lsp_workspace_symbols<cr>", desc = "Workspace symbols" },
                { "<leader>sW", "<cmd>FzfLua lsp_live_workspace_symbols<cr>", desc = "Live workspace symbols" },
                { "<leader>sd", "<cmd>FzfLua diagnostics_document<cr>", desc = "Document diagnostics" },
                { "<leader>sD", "<cmd>FzfLua diagnostics_workspace<cr>", desc = "Workspace diagnostics" },
                { "<leader>sa", "<cmd>FzfLua lsp_code_actions<cr>", desc = "Code actions" },
                { "<leader>sf", "<cmd>FzfLua lsp_finder<cr>", desc = "LSP finder (all locations)" },
                { "gr", "<cmd>FzfLua lsp_references<cr>", desc = "LSP references" },
                { "gd", "<cmd>FzfLua lsp_definitions<cr>", desc = "LSP definitions" },
                { "gi", "<cmd>FzfLua lsp_implementations<cr>", desc = "LSP implementations" },
                { "gt", "<cmd>FzfLua lsp_typedefs<cr>", desc = "LSP type definitions" },
                { "gD", "<cmd>FzfLua lsp_declarations<cr>", desc = "LSP declarations" },

                -- 其他
                { "<leader>tt", "<cmd>FzfLua builtin<cr>", desc = "FzfLua builtin" },
                { "<leader>th", "<cmd>FzfLua help_tags<cr>", desc = "Help tags" },
                { "<leader>tk", "<cmd>FzfLua keymaps<cr>", desc = "Keymaps" },
                { "<leader>tC", "<cmd>FzfLua commands<cr>", desc = "Commands" },
                { "<leader>tH", "<cmd>FzfLua command_history<cr>", desc = "Command history" },
                { "<leader>t/", "<cmd>FzfLua search_history<cr>", desc = "Search history" },
                { "<leader>tq", "<cmd>FzfLua quickfix<cr>", desc = "Quickfix" },
                { "<leader>tQ", "<cmd>FzfLua quickfix_stack<cr>", desc = "Quickfix stack" },
                { "<leader>tl", "<cmd>FzfLua loclist<cr>", desc = "Location list" },
                { "<leader>tS", "<cmd>FzfLua loclist_stack<cr>", desc = "Location list stack" },
                { "<leader>tr", "<cmd>FzfLua resume<cr>", desc = "Resume last search" },
                { "<leader>tc", "<cmd>FzfLua colorschemes<cr>", desc = "Colorschemes" },
                { "<leader>tT", "<cmd>FzfLua tabs<cr>", desc = "Tabs" },
                { "<leader>tM", "<cmd>FzfLua marks<cr>", desc = "Marks" },
                { "<leader>tR", "<cmd>FzfLua registers<cr>", desc = "Registers" },
                { "<leader>tj", "<cmd>FzfLua jumps<cr>", desc = "Jumps" },
                { "<leader>tA", "<cmd>FzfLua autocmds<cr>", desc = "Autocmds" },
            }

            -- 仅在非 Windows 系统添加 man pages 快捷键
            if not is_windows then
                table.insert(keys, { "<leader>tm", "<cmd>FzfLua man_pages<cr>", desc = "Man pages" })
            end

            return keys
        end,
    },
}
