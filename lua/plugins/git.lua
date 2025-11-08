return
--- @type LazySpec
{
    {
        "echasnovski/mini.diff",
        version = "*",
        event = { "BufReadPost", "BufNewFile" }, -- 需要实时显示 diff
        opts = {},
    },
    {
        "rbong/vim-flog",
        cmd = { "Flog", "Flogsplit", "Floggit" }, -- 命令触发
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
        cmd = "Neogit", -- 命令触发
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
        cmd = { "DiffviewOpen", "DiffviewFileHistory" }, -- 命令触发
    },
    {
        "FabijanZulj/blame.nvim",
        cmd = { "BlameToggle", "BlameEnable" }, -- 命令触发
        opts = {},
        keys = {
            { "<leader>bt", "<cmd>BlameToggle<cr>", desc = "Blame toggle" },
        },
    },
    {
        "akinsho/git-conflict.nvim",
        event = { "BufReadPost", "BufNewFile" }, -- 需要检测冲突标记
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
