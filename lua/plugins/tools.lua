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
        event = "VeryLazy",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {},
    },
    {
        "simnalamburt/vim-mundo",
        event = "VeryLazy",
        keys = {
            -- stylua: ignore
            { "<leader>ud", "<CMD>MundoToggle<CR>", mode = { "n" }, desc = "Toggle Mundo" },
        },
    },
    {
        "stevearc/stickybuf.nvim",
        event = "VeryLazy",
        opts = {},
    },
    {
        "max397574/better-escape.nvim",
        event = "VeryLazy",
        opts = {
            default_mappings = false,
            mappings = {
                i = { j = { k = "<Esc>" } },
                c = { j = { k = "<Esc>" } },
                t = { j = { k = "<C-\\><C-n>" } },
                v = { j = { k = "<Esc>" } },
                s = { j = { k = "<Esc>" } },
            },
        },
    },
    {
        "chrishrb/gx.nvim",
        event = "VeryLazy",
        keys = {
            { "gx", "<cmd>Browse<cr>", mode = { "n", "x" }, desc = "Browse URL" },
        },
        init = function()
            vim.g.netrw_nogx = 1 -- disable netrw gx
        end,
        dependencies = { "nvim-lua/plenary.nvim" }, -- Required for Neovim < 0.10.0
        config = true, -- default settings
        submodules = false, -- not needed, submodules are required only for tests
    },
    {
        "stevearc/quicker.nvim",
        event = "FileType qf",
        ---@module "quicker"
        ---@type quicker.SetupOptions
        opts = {},
    },
    {
        "stevearc/overseer.nvim",
        event = "VeryLazy",
        opts = {},
    },
    {
        "NStefan002/screenkey.nvim",
        event = "VeryLazy",
        version = "*", -- or branch = "dev", to use the latest commit
    },
    {
        "OXY2DEV/helpview.nvim",
        event = "VeryLazy",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
    },
    {
        "tweekmonster/helpful.vim",
        event = "VeryLazy",
    },
    {
        "2kabhishek/termim.nvim",
        event = "VeryLazy",
        cmd = { "Fterm", "FTerm", "Sterm", "STerm", "Vterm", "VTerm" },
    },
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        ---@type snacks.Config
        opts = {
            bigfile = { enabled = true },
            input = { enabled = true },
            picker = { enabled = true },
            quickfile = { enabled = true },
        },

        keys = {
            -- stylua: ignore
            { "<leader>lg", function() Snacks.lazygit() end, desc = "Lazygit" },
            -- stylua: ignore
            { "<leader>n", function() Snacks.picker.notifications() end, desc = "Notification History" },
        },
    },
    {
        "ovk/endec.nvim",
        event = "VeryLazy",
        opts = {
            -- Override default configuration here
        },
    },
    {
        "ellisonleao/dotenv.nvim",
        event = "VeryLazy",
        opts = {
            {
                enable_on_load = false,
            },
        },
    },
    {
        "tpope/vim-repeat",
    },
    {
        "MonsieurTib/package-ui.nvim",
        event = "VeryLazy",
        config = function()
            require("package-ui").setup()
        end,
    },
    {
        "bassamsdata/namu.nvim",
        opts = {
            global = {},
            namu_symbols = { -- Specific Module options
                options = {},
            },
        },
        keys = {
            { "<leader>ss", ":Namu symbols<cr>", mode = { "n" }, desc = "Jump to LSP symbol" },
            { "<leader>sw", ":Namu workspace<cr>", mode = { "n" }, desc = "LSP Symbols - Workspace" },
        },
    },
{
    "hat0uma/prelive.nvim",
    event = "VeryLazy",
    cmd = {
        "PreLiveGo",
        "PreLiveStatus",
        "PreLiveClose",
        "PreLiveCloseAll",
        "PreLiveLog",
    },
    opts = {
        server = {
            -- 强烈建议不要暴露到外部网络
            host = "127.0.0.1",
            -- 如果值为 0，服务器将绑定到随机端口
            port = 2255,
        },
        log = {
            print_level = vim.log.levels.WARN,
            file_level = vim.log.levels.DEBUG,
            max_file_size = 1 * 1024 * 1024,
            max_backups = 3,
        },
    },
    keys = {
        { "<leader>ps", "<cmd>PreLiveGo<cr>", mode = { "n" }, desc = "PreLive: Start server" },
        { "<leader>pt", "<cmd>PreLiveStatus<cr>", mode = { "n" }, desc = "PreLive: Status" },
        { "<leader>pc", "<cmd>PreLiveClose<cr>", mode = { "n" }, desc = "PreLive: Close" },
        { "<leader>pa", "<cmd>PreLiveCloseAll<cr>", mode = { "n" }, desc = "PreLive: Close all" },
        { "<leader>pl", "<cmd>PreLiveLog<cr>", mode = { "n" }, desc = "PreLive: View logs" },
    },
},
}
