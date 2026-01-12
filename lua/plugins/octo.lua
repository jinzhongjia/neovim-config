return
--- @type LazySpec
{
    {
        "pwntester/octo.nvim",
        cmd = "Octo",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
        },
        opts = {
            picker = "snacks",
            enable_builtin = true,
        },
        keys = {
            { "<leader>oi", "<cmd>Octo issue list<CR>", desc = "List issues" },
            { "<leader>op", "<cmd>Octo pr list<CR>", desc = "List PRs" },
            { "<leader>oP", "<cmd>Octo pr<CR>", desc = "Current branch PR" },
            { "<leader>oc", "<cmd>Octo pr checks<CR>", desc = "PR CI checks" },
            { "<leader>or", "<cmd>Octo review start<CR>", desc = "Start PR review" },
            { "<leader>oR", "<cmd>Octo review resume<CR>", desc = "Resume PR review" },
            { "<leader>os", "<cmd>Octo search<CR>", desc = "Search GitHub" },
        },
    },
}
