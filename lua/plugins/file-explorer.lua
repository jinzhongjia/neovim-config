return
--- @type LazySpec
{
    {
        "nvim-tree/nvim-tree.lua",
        event = "VeryLazy",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
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
        },
        keys = {
            { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "NvimTree" },
        },
    },
}