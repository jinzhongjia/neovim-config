-- manager lazy.nvim self
return
--- @type LazySpec
{
    {
        "stevearc/oil.nvim",
        lazy = false,
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            -- Oil will take over directory buffers (e.g. `vim .` or `:e src/`)
            default_file_explorer = true,
            columns = {
                "icon",
                -- "permissions",
                -- "size",
                -- "mtime",
            },
            buf_options = {
                buflisted = false,
                bufhidden = "hide",
            },
            win_options = {
                wrap = false,
                signcolumn = "yes:2",
                cursorcolumn = false,
                foldcolumn = "0",
                spell = false,
                list = false,
                conceallevel = 3,
                concealcursor = "nvic",
            },
            delete_to_trash = false,
            skip_confirm_for_simple_edits = false,
            prompt_save_on_select_new_entry = true,
            cleanup_delay_ms = 2000,
            lsp_file_methods = {
                enabled = true,
                timeout_ms = 1000,
                autosave_changes = false,
            },
            constrain_cursor = "editable",
            watch_for_changes = false,
            keymaps = {
                ["g?"] = "actions.show_help",
                ["<CR>"] = "actions.select",
                ["sv"] = { "actions.select", opts = { vertical = true }, desc = "Open in vertical split" },
                ["sh"] = { "actions.select", opts = { horizontal = true }, desc = "Open in horizontal split" },
                ["<C-t>"] = { "actions.select", opts = { tab = true }, desc = "Open in new tab" },
                ["<C-p>"] = "actions.preview",
                ["<C-c>"] = { "actions.close", mode = "n" },
                ["q"] = { "actions.close", mode = "n", desc = "Close oil" },
                ["<C-r>"] = "actions.refresh",
                ["-"] = { "actions.parent", desc = "Go to parent directory" },
                ["_"] = { "actions.open_cwd", desc = "Open current working directory" },
                ["`"] = { "actions.cd", desc = "Change directory" },
                ["~"] = { "actions.cd", opts = { scope = "tab" }, desc = "Change directory (tab-scoped)" },
                ["gs"] = { "actions.change_sort", desc = "Change sort order" },
                ["gx"] = "actions.open_external",
                ["g."] = { "actions.toggle_hidden", desc = "Toggle hidden files" },
                ["g\\"] = { "actions.toggle_trash", desc = "Toggle trash" },
            },
            use_default_keymaps = true,
            view_options = {
                show_hidden = false,
                is_hidden_file = function(name, bufnr)
                    return vim.startswith(name, ".")
                end,
                is_always_hidden = function(name, bufnr)
                    return false
                end,
                natural_order = "fast",
                case_insensitive = false,
                sort = {
                    { "type", "asc" },
                    { "name", "asc" },
                },
            },
            float = {
                padding = 2,
                max_width = 0,
                max_height = 0,
                border = "rounded",
                win_options = {
                    winblend = 0,
                },
                preview_split = "auto",
            },
            preview_win = {
                update_on_cursor_moved = true,
                preview_method = "fast_scratch",
                disable_preview = function(filename)
                    return false
                end,
            },
            confirmation = {
                max_width = 0.9,
                min_width = { 40, 0.4 },
                max_height = 0.9,
                min_height = { 5, 0.1 },
                border = "rounded",
                win_options = {
                    winblend = 0,
                },
            },
            progress = {
                max_width = 0.9,
                min_width = { 40, 0.4 },
                max_height = { 10, 0.9 },
                min_height = { 5, 0.1 },
                border = "rounded",
                minimized_border = "none",
                win_options = {
                    winblend = 0,
                },
            },
            ssh = {
                border = "rounded",
            },
            keymaps_help = {
                border = "rounded",
            },
        },
        keys = {
            { "-", "<CMD>Oil<CR>", desc = "Open parent directory" },
            { "<leader>-", "<CMD>Oil --float<CR>", desc = "Open parent directory (float)" },
        },
    },
    {
        "JezerM/oil-lsp-diagnostics.nvim",
        dependencies = { "stevearc/oil.nvim" },
        opts = {},
    },
    {
        "refractalize/oil-git-status.nvim",
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
            disable_netrw = false, -- Let oil.nvim handle netrw
            hijack_netrw = false, -- Let oil.nvim handle netrw
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
