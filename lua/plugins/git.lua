return
--- @type LazySpec
{
    {
        "echasnovski/mini.diff",
        version = "*",
        event = "VeryLazy",
        opts = {},
    },
    {
        "rbong/vim-flog",
        event = "VeryLazy",
        dependencies = {
            "tpope/vim-fugitive",
        },
    },
    {
        "NeogitOrg/neogit",
        dependencies = {
            "nvim-lua/plenary.nvim", -- required
            "sindrets/diffview.nvim", -- optional - Diff integration

            -- Only one of these is needed.
            "folke/snacks.nvim",
        },
        event = "VeryLazy",
        opts = {
            mappings = {
                finder = {
                    ["<C-j>"] = "Next",
                    ["<C-k>"] = "Previous",
                },
            },
            integrations = {
                snacks = true,
            },
            graph_style = "unicode",
        },
        keys = {
            { "<leader>ng", "<cmd>Neogit<cr>", desc = "NeoGit" },
        },
    },
    {
        "sindrets/diffview.nvim",
        event = "VeryLazy",
    },
    {
        "FabijanZulj/blame.nvim",
        event = "VeryLazy",
        opts = {},
        keys = {
            { "<leader>bt", "<cmd>BlameToggle<cr>", desc = "Blame toogle" },
        },
    },
    {
        "akinsho/git-conflict.nvim",
        event = "VeryLazy",
        version = "*",
        config = true,
    },
    {
        "isakbm/gitgraph.nvim",
        dependencies = { "sindrets/diffview.nvim" },
        ---@type I.GGConfig
        opts = {
            symbols = {
                merge_commit = "M",
                commit = "*",
            },
            format = {
                timestamp = "%H:%M:%S %d-%m-%Y",
                fields = { "hash", "timestamp", "author", "branch_name", "tag" },
            },
            hooks = {
                -- Check diff of a commit
                on_select_commit = function(commit)
                    vim.notify("DiffviewOpen " .. commit.hash .. "^!")
                    vim.cmd(":DiffviewOpen " .. commit.hash .. "^!")
                end,
                -- Check diff from commit a -> commit b
                on_select_range_commit = function(from, to)
                    vim.notify("DiffviewOpen " .. from.hash .. "~1.." .. to.hash)
                    vim.cmd(":DiffviewOpen " .. from.hash .. "~1.." .. to.hash)
                end,
            },
        },
        keys = {
            {
                "<leader>gl",
                function()
                    require("gitgraph").draw({}, { all = true, max_count = 5000 })
                end,
                desc = "GitGraph - Draw",
            },
        },
    },
}
