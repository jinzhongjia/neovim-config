-- manager lazy.nvim self
return
--- @type LazySpec
{
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        opts = {
            disable_netrw = true,
            sync_root_with_cwd = true,
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

                vim.keymap.set("n", "sv", api.node.open.vertical, opts("Open: Vertical Split"))
                vim.keymap.set("n", "sh", api.node.open.horizontal, opts("Open: Horizontal Split"))
            end,
        },
        keys = {
            { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "NvimTree" },
        },
    },
}
