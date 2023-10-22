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
        event = "VeryLazy",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "antosha417/nvim-lsp-file-operations",
            "echasnovski/mini.base16",
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
            -- "f-person/git-blame.nvim",
        },
        config = function()
            require("plugin.lualine")
        end,
    },
    -- windows
    {
        "anuvyklack/windows.nvim",
        event = "VeryLazy",
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
    {
        "nvim-treesitter/nvim-treesitter",
        dependencies = {
            "JoosepAlviste/nvim-ts-context-commentstring",
        },
        event = "VeryLazy",
        build = ":TSUpdate",
        config = function()
            require("plugin.nvim-treesitter")
        end,
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        enabled = false,
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
            "williamboman/mason-lspconfig.nvim",
            {
                "mfussenegger/nvim-dap",
                dependencies = {
                    "rcarriga/nvim-dap-ui",
                },
            },
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
            -- "hrsh7th/cmp-path",
            -- async path
            "FelipeLema/cmp-async-path",
            "lukas-reineke/cmp-rg",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-nvim-lsp-document-symbol",
            "hrsh7th/cmp-nvim-lsp-signature-help",
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
        event = "BufReadPost",
        config = function()
            require("plugin.nvim-ufo")
        end,
    },
    -- Folding preview, by default h and l keys are used.
    -- On first press of h key, when cursor is on a closed fold, the preview will be shown.
    -- On second press the preview will be closed and fold will be opened.
    -- When preview is opened, the l key will close it and open fold. In all other cases these keys will work as usual.
    {
        "anuvyklack/fold-preview.nvim",
        event = "VeryLazy",
        dependencies = "anuvyklack/keymap-amend.nvim",
        config = true,
    },
    {
        "stevearc/conform.nvim",
        event = "VeryLazy",
        config = function()
            require("plugin.conform")
        end,
    },
    {
        "folke/trouble.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {},
    },
    {
        "Bekaboo/dropbar.nvim",
        event = "VeryLazy",
        -- optional, but required for fuzzy finder support
        dependencies = {
            "nvim-telescope/telescope-fzf-native.nvim",
        },
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

    -- fugitive
    {
        "tpope/vim-fugitive",
        dependencies = "rbong/vim-flog",
        event = "VeryLazy",
    },
    {
        "voldikss/vim-translator",
        event = "VeryLazy",
        config = function()
            require("plugin.vim-translator")
        end,
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
        "levouh/tint.nvim",
        event = "VeryLazy",
        config = function()
            ---@diagnostic disable-next-line: missing-parameter
            require("tint").setup()
        end,
    },

    {
        "nmac427/guess-indent.nvim",
        event = "VeryLazy",
        config = function()
            require("guess-indent").setup()
        end,
    },

    {
        "goolord/alpha-nvim",
        event = "VIMEnter",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("plugin.alpha")
        end,
    },
    {
        "sindrets/diffview.nvim",
        event = "VeryLazy",
        config = function()
            require("diffview").setup()
        end,
    },
    {
        "shellRaining/hlchunk.nvim",
        event = { "UIEnter" },
        enabled = true,
        config = function()
            require("hlchunk").setup({})
        end,
    },

    -- colorscheme
    {
        "rebelot/kanagawa.nvim",
        -- event = "UIEnter",
        enabled = true,
        priority = 1000,
        config = function()
            -- vim.cmd("colorscheme kanagawa")
        end,
    },
    {
        "catppuccin/nvim",
        enabled = true,
        name = "catppuccin",
        priority = 1000,
        config = function()
            local catppuccin = require("catppuccin")

            catppuccin.setup({
                flavour = "mocha",
            })

            -- vim.cmd.colorscheme("catppuccin")
        end,
    },
    {
        "projekt0n/github-nvim-theme",
        enabled = true,
        priority = 1000, -- make sure to load this before all the other start plugins
        config = function()
            require("github-theme").setup({})
            -- vim.cmd("colorscheme github_dark_dimmed")
        end,
    },
    {
        "Mofiqul/vscode.nvim",
        enabled = true,
        priority = 1000,
        config = function()
            local vscode = require("vscode")
            vscode.setup()
            -- vscode.load()
        end,
    },
    {
        "Everblush/nvim",
        enabled = true,
        name = "everblush",
        priority = 1000,
        config = function()
            -- vim.cmd("colorscheme everblush")
        end,
    },
    {
        "Mofiqul/adwaita.nvim",
        enabled = true,
        priority = 1000,
        config = function()
            vim.g.adwaita_darker = false -- for darker version
            vim.g.adwaita_disable_cursorline = false -- to disable cursorline
            vim.g.adwaita_transparent = false -- makes the background transparent
            -- vim.cmd([[colorscheme adwaita]])
        end,
    },
    {
        "JoosepAlviste/palenightfall.nvim",
        enabled = true,
        priority = 1000,
        config = function()
            -- require("palenightfall").setup()
        end,
    },
    {
        "Yagua/nebulous.nvim",
        enabled = true,
        priority = 1000,
        config = function()
            -- more details, see github
            -- require("nebulous").setup({
            --     variant = "fullmoon",
            -- })
        end,
    },
    {
        "savq/melange-nvim",
        enabled = true,
        priority = 1000,
        config = function()
            -- vim.cmd([[colorscheme melange]])
        end,
    },
    {
        "askfiy/visual_studio_code",
        enabled = true,
        priority = 1000,
        config = function()
            -- vim.cmd([[colorscheme visual_studio_code]])
        end,
    },
    {
        "rockyzhang24/arctic.nvim",
        branch = "v2",
        enabled = true,
        priority = 1000,
        dependencies = { "rktjmp/lush.nvim" },
        config = function()
            vim.cmd([[colorscheme arctic]])
        end,
    },
    {
        "rose-pine/neovim",
        name = "rose-pine",
        enabled = true,
        priority = 1000,
        config = function()
            require("rose-pine").setup({
                --- @usage 'auto'|'main'|'moon'|'dawn'
                variant = "auto",
            })

            -- Set colorscheme after options
            -- vim.cmd("colorscheme rose-pine")
        end,
    },
    {
        "uloco/bluloco.nvim",
        enabled = true,
        priority = 1000,
        dependencies = { "rktjmp/lush.nvim" },
        config = function()
            require("bluloco").setup({
                style = "auto", -- "auto" | "dark" | "light"
                transparent = false,
                italics = false,
                terminal = true, -- bluoco colors are enabled in gui terminals per default.
                guicursor = true,
            })

            -- vim.cmd[[colorscheme bluloco]]
        end,
    },
    {
        "ronisbr/nano-theme.nvim",
        enabled = true,
        priority = 1000,
        config = function()
            -- vim.cmd[[colorscheme nano-theme]]
        end,
    },

    -- some interesting plugin
    {
        "Eandrju/cellular-automaton.nvim",
        event = "VeryLazy",
    },
}, {
    dev = {
        path = "~/code",
        fallback = true,
    },
})
