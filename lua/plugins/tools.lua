-- some useful tools
return
--- @type LazySpec
{
    {
        "voldikss/vim-floaterm",
        event = "VeryLazy",
        init = function()
            vim.g.floaterm_width = 0.85
            vim.g.floaterm_height = 0.8
        end,
        keys = {
            { "ft", "<CMD>FloatermNew<CR>", mode = { "n", "t" }, desc = "floaterm new" },
            { "fj", "<CMD>FloatermPrev<CR>", mode = { "n", "t" }, desc = "floaterm prev" },
            { "fk", "<CMD>FloatermNext<CR>", mode = { "n", "t" }, desc = "floaterm next" },
            { "fs", "<CMD>FloatermToggle<CR>", mode = { "n", "t" }, desc = "floaterm toggel" },
            { "fc", "<CMD>FloatermKill<CR>", mode = { "n", "t" }, desc = "floaterm kill" },
        },
    },
    {
        "voldikss/vim-translator",
        event = "VeryLazy",
    },
    {
        "chrisgrieser/nvim-early-retirement",
        event = "VeryLazy",
        config = true,
    },
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {},
    },
    {
        "mbbill/undotree",
        event = "VeryLazy",
    },
    {
        "simnalamburt/vim-mundo",
        event = "VeryLazy",
    },
    {
        "skywind3000/asynctasks.vim",
        dependencies = {
            "skywind3000/asyncrun.vim",
        },
        event = "VeryLazy",
        init = function()
            vim.g.asyncrun_open = 6
        end,
    },
    {
        "stevearc/stickybuf.nvim",
        event = "VeryLazy",
        opts = {},
    },
    {
        "max397574/better-escape.nvim",
        event = "VeryLazy",
        opts = {},
    },
    {
        "itchyny/vim-highlighturl",
        event = "VeryLazy",
    },
    {
        "chrishrb/gx.nvim",
        keys = { { "gx", "<cmd>Browse<cr>", mode = { "n", "x" } } },
        cmd = { "Browse" },
        init = function()
            vim.g.netrw_nogx = 1 -- disable netrw gx
        end,
        dependencies = { "nvim-lua/plenary.nvim" }, -- Required for Neovim < 0.10.0
        config = true, -- default settings
        submodules = false, -- not needed, submodules are required only for tests
    },
}
