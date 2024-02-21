local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- manage itself
    "folke/lazy.nvim",
    -- file explorer
    {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        event = "UIEnter",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "antosha417/nvim-lsp-file-operations",
        },
        config = function()
            require("plugin.nvim-tree")
        end,
    },
    -- buffer line
    {
        "akinsho/bufferline.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "moll/vim-bbye",
        },
        event = "UIEnter",
        config = function()
            require("plugin.bufferline")
        end,
    },
    -- status line
    {
        "nvim-lualine/lualine.nvim",
        event = "UIEnter",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "jinzhongjia/git-blame.nvim",
            {
                "AndreM222/copilot-lualine",
                dependencies = "zbirenbaum/copilot.lua",
            },
        },
        config = function()
            require("plugin.lualine")
        end,
    },
    -- windows
    {
        "anuvyklack/windows.nvim",
        event = "VeryLazy",
        enabled = true,
        dependencies = "anuvyklack/middleclass",
        config = function()
            require("plugin.windows")
        end,
    },

    -- comment
    {
        "numToStr/Comment.nvim",
        dependencies = {
            "JoosepAlviste/nvim-ts-context-commentstring",
        },
        event = "VeryLazy",
        config = function()
            require("plugin.Comment")
        end,
    },
    -- lsp progress
    {
        "j-hui/fidget.nvim",
        branch = "legacy",
        event = "VeryLazy",
        config = function()
            require("plugin.fidget")
        end,
    },

    -- lspui
    {
        "jinzhongjia/LspUI.nvim",
        dev = true,
        event = "VeryLazy",
        config = function()
            require("plugin.LspUI")
        end,
    },
    {
        "jinzhongjia/Zig.nvim",
        dev = true,
        event = "VeryLazy",
        config = function()
            require("plugin.Zig")
        end,
    },
    -- symbol line
    {
        "stevearc/aerial.nvim",
        event = "VeryLazy",
        enabled = false,
        config = function()
            require("plugin.aerial")
        end,
    },
    -- floaterm
    {
        "voldikss/vim-floaterm",
        event = "VeryLazy",
        config = function()
            require("plugin.vim-floaterm")
        end,
    },
    -- gitsigns
    {
        "lewis6991/gitsigns.nvim",
        event = "VeryLazy",
        config = function()
            require("plugin.gitsigns")
        end,
    },
    -- treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        dependencies = {
            "JoosepAlviste/nvim-ts-context-commentstring",
        },
        event = "VeryLazy",
        build = function()
            require("nvim-treesitter.install").update({ with_sync = true })()
        end,
        config = function()
            require("plugin.nvim-treesitter")
        end,
    },
    -- indent blankline
    {
        "lukas-reineke/indent-blankline.nvim",
        event = "VeryLazy",
        config = function()
            require("plugin.indent-blankline")
        end,
    },
    {
        "williamboman/mason.nvim",
        event = "VeryLazy",
        dependencies = {
            "neovim/nvim-lspconfig",
            "creativenull/efmls-configs-nvim",
            "williamboman/mason-lspconfig.nvim",

            "b0o/schemastore.nvim",
            "folke/neodev.nvim",
        },
        config = function()
            require("plugin.mason")
        end,
    },
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            {
                "zbirenbaum/copilot-cmp",
                dependencies = {
                    "zbirenbaum/copilot.lua",
                    build = ":Copilot auth",
                    opts = {
                        suggestion = { enabled = false },
                        panel = { enabled = false },
                        filetypes = {
                            -- markdown = true,
                            -- help = true,
                            ["*"] = false,
                        },
                    },
                },
                config = function()
                    require("copilot_cmp").setup()
                end,
            },

            -- "hrsh7th/cmp-path",
            -- async path
            "FelipeLema/cmp-async-path",
            "lukas-reineke/cmp-rg",
            "hrsh7th/cmp-cmdline",
            --
            -- "L3MON4D3/LuaSnip",
            -- "saadparwaiz1/cmp_luasnip",
            "hrsh7th/vim-vsnip",
            "hrsh7th/cmp-vsnip",
            --- ui denpendences
            "onsails/lspkind-nvim",
            --- autopairs
            "windwp/nvim-autopairs",
            "rafamadriz/friendly-snippets",
        },
        event = "VeryLazy",
        config = function()
            require("plugin.cmp")
        end,
    },
    -- telescope
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            -- "nvim-telescope/telescope-dap.nvim",
            "debugloop/telescope-undo.nvim",
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
            },
            "nvim-telescope/telescope-live-grep-args.nvim",
        },
        event = "VeryLazy",
        config = function()
            require("plugin.telescope")
        end,
    },
    {
        "m-demare/hlargs.nvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
        event = "VeryLazy",
        config = function()
            require("plugin.hlargs")
        end,
    },
    -- ufo fold
    {
        "kevinhwang91/nvim-ufo",
        dependencies = {
            "kevinhwang91/promise-async",
            {
                "luukvbaal/statuscol.nvim",
                config = function()
                    local builtin = require("statuscol.builtin")
                    require("statuscol").setup({
                        relculright = true,
                        segments = {
                            { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
                            { text = { "%s" }, click = "v:lua.ScSa" },
                            { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
                        },
                    })
                end,
            },
        },
        event = "VeryLazy",
        config = function()
            require("plugin.nvim-ufo")
        end,
    },
    -- translator
    {
        "voldikss/vim-translator",
        event = "VeryLazy",
        config = function()
            require("plugin.vim-translator")
        end,
    },
    -- format
    {
        "stevearc/conform.nvim",
        event = "VeryLazy",
        enabled = true,
        config = function()
            require("plugin.conform")
        end,
    },
    -- trouble
    {
        "folke/trouble.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {},
    },
    -- winbar
    {
        "Bekaboo/dropbar.nvim",
        event = "VeryLazy",
        opts = {
            general = {
                update_events = {
                    win = {
                        "CursorHold",
                        "CursorHoldI",
                        "WinEnter",
                        "WinResized",
                    },
                },
            },
        },
        -- optional, but required for fuzzy finder support
        dependencies = {
            "nvim-telescope/telescope-fzf-native.nvim",
        },
    },
    -- indent
    {
        "nmac427/guess-indent.nvim",
        event = "VeryLazy",
        config = function()
            require("plugin.guess-indent")
        end,
    },
    -- board
    {
        "goolord/alpha-nvim",
        enabled = (vim.g.neovide ~= nil),
        event = "VIMEnter",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("plugin.alpha")
        end,
    },
    -- diffview
    {
        "sindrets/diffview.nvim",
        event = "VeryLazy",
        config = function()
            require("plugin.diffview")
        end,
    },
    -- terminal
    {
        "akinsho/toggleterm.nvim",
        event = "VeryLazy",
        config = function()
            require("plugin.toggleterm")
        end,
    },
    {
        "willothy/flatten.nvim",
        event = "VeryLazy",
        config = true,
    },
    {
        "chrisgrieser/nvim-early-retirement",
        config = true,
        event = "VeryLazy",
    },
    {
        "folke/zen-mode.nvim",
        event = "VeryLazy",
        opts = {},
    },
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        event = "VeryLazy",
        opts = {},
    },
    {
        "folke/twilight.nvim",
        event = "VeryLazy",
        opts = {},
    },
    {
        "tpope/vim-fugitive",
        dependencies = "rbong/vim-flog",
        event = "VeryLazy",
    },
    {
        "mbbill/undotree",
        event = "VeryLazy",
    },
    {
        "skywind3000/asynctasks.vim",
        dependencies = {
            "skywind3000/asyncrun.vim",
        },
        event = "VeryLazy",
        config = function()
            vim.g.asyncrun_open = 6
        end,
    },
    {
        "RRethy/vim-illuminate",
        event = "VeryLazy",
        config = function()
            require("illuminate").configure({
                filetypes_denylist = {
                    "dirbuf",
                    "dirvish",
                    "fugitive",
                    "NvimTree",
                    "Outline",
                    "LspUI-rename",
                    "LspUI-diagnostic",
                    "LspUI-code_action",
                    "LspUI-definition",
                    "LspUI-type_definition",
                    "LspUI-declaration",
                    "LspUI-reference",
                    "LspUI-implementation",
                },
            })
        end,
    },
    {
        "wavded/vim-stylus",
        event = "VeryLazy",
    },
    {
        "stevearc/stickybuf.nvim",
        event = "VeryLazy",
        opts = {},
    },
    {
        "jeffkreeftmeijer/vim-numbertoggle",
        event = "VeryLazy",
    },
    {
        "tpope/vim-endwise",
        event = "VeryLazy",
    },
    {
        "nacro90/numb.nvim",
        evnet = "VeryLazy",
        config = true,
    },
    {
        "jinzhongjia/outline.nvim",
        dev = true,
        lazy = true,
        cmd = { "Outline", "OutlineOpen" },
        keys = { -- Example mapping to toggle outline
            { "<leader>a", "<cmd>Outline<CR>", desc = "Toggle outline" },
        },
        opts = {
            -- Your setup opts here
        },
    },

    -- unpack(require("theme").theme()),
}, {
    dev = {
        path = vim.fn.expand("~/code"),
        fallback = true,
    },
    checker = {
        enabled = true,
        notify = false,
    },
    install = {
        colorscheme = { "arctic" },
    },
})
