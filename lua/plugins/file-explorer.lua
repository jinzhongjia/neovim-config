-- manager lazy.nvim self
return
--- @type LazySpec
{
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
            disable_netrw = true,
            sync_root_with_cwd = true,
            update_focused_file = {
                enable = true,
            },
            filters = {
                dotfiles = true,
                custom = { "node_modules" },
            },
            actions = {
                open_file = {
                    resize_window = true,
                    quit_on_open = true,
                },
            },
            git = {
                timeout = 1000,
            },
            diagnostics = {
                enable = true,
                show_on_dirs = true,
            },
            modified = {
                enable = true,
            },
            select_prompts = true,
            -- keymap override
            on_attach = function(buffer_id)
                local api = require("nvim-tree.api")

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
