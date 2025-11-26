-- 注意: oil.nvim 已被 fyler.nvim 替代
-- 如需恢复 oil.nvim，将 enabled = false 改为 true
return
--- @type LazySpec
{
    -- ===== fyler.nvim - 基于 buffer 的文件管理器，支持树形视图 =====
    {
        "A7Lavinraj/fyler.nvim",
        lazy = false,
        dependencies = { "echasnovski/mini.icons" },
        opts = {
            integrations = {
                icon = "mini_icons",
            },
            views = {
                finder = {
                    close_on_select = true,
                    confirm_simple = false,
                    default_explorer = true, -- 接管 netrw
                    delete_to_trash = false,
                    git_status = {
                        enabled = true,
                        symbols = {
                            Untracked = "?",
                            Added = "+",
                            Modified = "*",
                            Deleted = "x",
                            Renamed = ">",
                            Copied = "~",
                            Conflict = "!",
                            Ignored = "#",
                        },
                    },
                    indentscope = {
                        enabled = true,
                        group = "FylerIndentMarker",
                        marker = "│",
                    },
                    mappings = {
                        ["q"] = "CloseView",
                        ["<CR>"] = "Select",
                        ["<C-t>"] = "SelectTab",
                        ["|"] = "SelectVSplit",
                        ["-"] = "SelectSplit",
                        ["^"] = "GotoParent",
                        ["="] = "GotoCwd",
                        ["."] = "GotoNode",
                        ["#"] = "CollapseAll",
                        ["<BS>"] = "CollapseNode",
                        -- 自定义快捷键，类似 oil.nvim
                        ["sv"] = "SelectVSplit",
                        ["sh"] = "SelectSplit",
                    },
                    follow_current_file = true,
                    watcher = {
                        enabled = true,
                    },
                    win = {
                        border = "rounded",
                        kind = "replace",
                        kinds = {
                            float = {
                                height = "70%",
                                width = "70%",
                                top = "15%",
                                left = "15%",
                            },
                            replace = {},
                            split_left = {
                                width = "30%",
                            },
                            split_left_most = {
                                width = "30%",
                                win_opts = {
                                    winfixwidth = true,
                                },
                            },
                        },
                        win_opts = {
                            concealcursor = "nvic",
                            conceallevel = 3,
                            cursorline = true,
                            number = false,
                            relativenumber = false,
                            wrap = false,
                            signcolumn = "no",
                        },
                    },
                },
            },
        },
        keys = {
            {
                "-",
                function()
                    require("fyler").open({ kind = "replace" })
                end,
                desc = "Open file manager",
            },
            {
                "<leader>-",
                function()
                    require("fyler").open({ kind = "float" })
                end,
                desc = "Open file manager (float)",
            },
            {
                "<leader>fe",
                function()
                    require("fyler").toggle({ kind = "split_left_most" })
                end,
                desc = "Toggle file explorer (sidebar)",
            },
        },
    },
    -- ===== oil.nvim - 已禁用，被 fyler.nvim 替代 =====
    {
        "stevearc/oil.nvim",
        enabled = false, -- 已被 fyler.nvim 替代
        lazy = false,
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            default_file_explorer = true,
            columns = { "icon" },
        },
        keys = {
            { "-", "<CMD>Oil<CR>", desc = "Open parent directory" },
            { "<leader>-", "<CMD>Oil --float<CR>", desc = "Open parent directory (float)" },
        },
    },
    {
        "JezerM/oil-lsp-diagnostics.nvim",
        enabled = false, -- oil.nvim 已禁用
        dependencies = { "stevearc/oil.nvim" },
        opts = {},
    },
    {
        "refractalize/oil-git-status.nvim",
        enabled = false, -- oil.nvim 已禁用
        dependencies = { "stevearc/oil.nvim" },
        opts = {
            show_ignored = true,
        },
    },
    {
        "nvim-tree/nvim-tree.lua",
        event = "UIEnter",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            {
                "b0o/nvim-tree-preview.lua",
                dependencies = {
                    "nvim-lua/plenary.nvim",
                },
            },
        },
        opts = {
            view = { adaptive_size = true },
            disable_netrw = false, -- Let fyler.nvim handle netrw
            hijack_netrw = false, -- Let fyler.nvim handle netrw
            sync_root_with_cwd = true,
            update_focused_file = { enable = true },
            filters = {
                dotfiles = true,
                custom = { "node_modules", "^.git$" },
            },
            actions = {
                open_file = {
                    resize_window = true,
                    quit_on_open = true,
                },
            },
            live_filter = {
                prefix = "[FILTER]: ",
                always_show_folders = false, -- Turn into false from true by default
            },
            git = { timeout = 1000 },
            diagnostics = {
                enable = true,
                show_on_dirs = true,
            },
            select_prompts = true,
            -- keymap override
            on_attach = function(buffer_id)
                local api = require("nvim-tree.api")
                local git_add = function()
                    local node = api.tree.get_node_under_cursor()
                    local gs = node.git_status.file

                    -- If the current node is a directory get children status
                    if gs == nil then
                        gs = (node.git_status.dir.direct ~= nil and node.git_status.dir.direct[1])
                            or (node.git_status.dir.indirect ~= nil and node.git_status.dir.indirect[1])
                    end

                    -- If the file is untracked, unstaged or partially staged, we stage it
                    if gs == "??" or gs == "MM" or gs == "AM" or gs == " M" then
                        vim.cmd("silent !git add " .. node.absolute_path)

                    -- If the file is staged, we unstage
                    elseif gs == "M " or gs == "A " then
                        vim.cmd("silent !git restore --staged " .. node.absolute_path)
                    end

                    api.tree.reload()
                end
                local function open_tab_silent(node)
                    api.node.open.tab(node)
                    vim.cmd.tabprev()
                end

                local function opts(desc)
                    return {
                        desc = "nvim-tree: " .. desc,
                        buffer = buffer_id,
                        noremap = true,
                        silent = true,
                        nowait = true,
                    }
                end
                -- use add default mappings
                api.config.mappings.default_on_attach(buffer_id)
                vim.keymap.del("n", "s", opts("remove s keymap"))

                vim.keymap.set("n", "sv", api.node.open.vertical, opts("Open: Vertical Split"))
                vim.keymap.set("n", "sh", api.node.open.horizontal, opts("Open: Horizontal Split"))

                vim.keymap.set("n", "ga", git_add, opts("Git Add"))

                vim.keymap.set("n", "T", open_tab_silent, opts("Open Tab Silent"))

                local preview = require("nvim-tree-preview")

                vim.keymap.set("n", "P", preview.watch, opts("Preview (Watch)"))
                vim.keymap.set("n", "<Esc>", preview.unwatch, opts("Close Preview/Unwatch"))
                vim.keymap.set("n", "<C-f>", function()
                    return preview.scroll(4)
                end, opts("Scroll Down"))
                vim.keymap.set("n", "<C-b>", function()
                    return preview.scroll(-4)
                end, opts("Scroll Up"))

                vim.keymap.set("n", "<Tab>", function()
                    local ok, node = pcall(api.tree.get_node_under_cursor)
                    if ok and node then
                        if node.type == "directory" then
                            api.node.open.edit()
                        else
                            preview.node(node, { toggle_focus = true })
                        end
                    end
                end, opts("Preview"))
            end,
        },
        keys = {
            { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "NvimTree" },
        },
    },
    {
        "antosha417/nvim-lsp-file-operations",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-tree.lua",
        },
        event = "VeryLazy",
        opts = {},
    },
}
